import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/notification.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';

final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);

final notificationListProvider =
    StateNotifierProvider<
      NotificationListNotifier,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      return NotificationListNotifier(ref);
    });

class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final Ref _ref;
  Timer? _pollingTimer;

  NotificationListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    fetchNotifications();
    // Start polling for unread count every 1 hour
    _pollingTimer = Timer.periodic(const Duration(hours: 1), (_) {
      fetchUnreadCount();
    });
    fetchUnreadCount(); // Initial fetch
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        state = const AsyncValue.loading();
      }
      final repo = _ref.read(dataRepositoryProvider);
      final notifications = await repo.getNotifications();
      state = AsyncValue.data(notifications);
      // Update unread count as well
      fetchUnreadCount();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logRead(String id) async {
    try {
      // Check if already read to avoid unnecessary API call
      if (state.hasValue) {
        try {
          final notification = state.value!.firstWhere((n) => n.id == id);
          if (notification.isRead) return;
        } catch (_) {
          // Notification might not be in the current list, proceed safely
        }
      }

      final repo = _ref.read(dataRepositoryProvider);
      await repo.markNotificationAsRead(id);

      // Optimistically update list
      if (state.hasValue) {
        final updated = state.value!.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();
        state = AsyncValue.data(updated);
      }

      fetchUnreadCount();
    } catch (e) {
      // Ideally handle error
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllRead() async {
    try {
      // Check if there are any unread notifications
      if (state.hasValue) {
        final hasUnread = state.value!.any((n) => !n.isRead);
        if (!hasUnread) return;
      }

      final repo = _ref.read(dataRepositoryProvider);
      await repo.markAllNotificationsAsRead();

      // Optimistically update list
      if (state.hasValue) {
        final updated = state.value!
            .map((n) => n.copyWith(isRead: true))
            .toList();
        state = AsyncValue.data(updated);
      }

      fetchUnreadCount();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final repo = _ref.read(dataRepositoryProvider);
      final count = await repo.getUnreadNotificationCount();
      _ref.read(unreadNotificationCountProvider.notifier).state = count;
    } catch (e) {
      // ignore errors during silent polling
      print('Error polling unread count: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
