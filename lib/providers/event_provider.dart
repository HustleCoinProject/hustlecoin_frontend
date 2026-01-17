import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/event.dart';
import 'package:hustlecoin/data/repositories/data_repository.dart';
import 'package:hustlecoin/providers/user_provider.dart';

import 'package:hustlecoin/providers/foundational_providers.dart';

final eventsListProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final repository = ref.watch(dataRepositoryProvider);
  ref.watch(userControllerProvider);
  return repository.getEvents();
});

final eventLeaderboardProvider = FutureProvider.family
    .autoDispose<List<EventLeaderboardEntry>, String>((ref, eventId) async {
      final repository = ref.watch(dataRepositoryProvider);
      return repository.getEventLeaderboard(eventId);
    });

class JoinEventController extends StateNotifier<AsyncValue<void>> {
  final DataRepository _repository;
  final Ref _ref;

  JoinEventController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> joinEvent(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.joinEvent(eventId);
      _ref.invalidate(eventsListProvider);
      _ref.invalidate(userControllerProvider);
      // Invalidate the specific event's leaderboard to show user is now joined
      _ref.invalidate(eventLeaderboardProvider(eventId));
    });
  }
}

final joinEventControllerProvider =
    StateNotifierProvider<JoinEventController, AsyncValue<void>>((ref) {
      return JoinEventController(ref.watch(dataRepositoryProvider), ref);
    });
