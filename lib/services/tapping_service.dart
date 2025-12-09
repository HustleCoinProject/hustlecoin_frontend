import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/foundational_providers.dart';
import '../providers/user_provider.dart';
import '../providers/tapping_status_provider.dart';

class TappingService {
  final Ref _ref;
  Timer? _batchTimer;
  int _pendingTaps = 0;
  bool _isSubmitting = false;

  TappingService(this._ref);

  void addTap() {
    if (_isSubmitting) return;

    // Check if we can tap based on current tapping status
    final tappingStatusNotifier = _ref.read(tappingStatusProvider.notifier);
    if (tappingStatusNotifier.hasReachedDailyLimit) {
      print('Cannot tap: Daily limit reached');
      return;
    }

    _pendingTaps++;

    // Update balance locally immediately (HC only, let server provide actual rank points)
    // The server will provide the accurate rank points earned when we submit the batch
    _ref.read(userControllerProvider.notifier).optimisticallyUpdateBalance(1, rankPointsGained: 0);

    // Cancel existing timer and start a new one (2 seconds)
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(seconds: 2), _submitBatch);
  }

  Future<void> _submitBatch() async {
    if (_pendingTaps == 0 || _isSubmitting) return;

    _isSubmitting = true;
    final tapsToSubmit = _pendingTaps;
    _pendingTaps = 0; // Reset the counter

    try {
      final dataRepository = _ref.read(dataRepositoryProvider);
      final tapResponse = await dataRepository.submitTaps(tapsToSubmit);

      // Update tapping status based on server response
      _ref.read(tappingStatusProvider.notifier).updateFromTapResponse(tapResponse);

      // Refresh user data to get the corrected balance from server
      _ref.invalidate(userControllerProvider);
    } catch (e) {
      // Add the taps back to pending if submission failed
      _pendingTaps += tapsToSubmit;
      print('Failed to submit taps: $e');
      
      // Refresh tapping status on error to get current state from server
      _ref.read(tappingStatusProvider.notifier).refreshStatus();
    } finally {
      _isSubmitting = false;
    }
  }

  void dispose() {
    _batchTimer?.cancel();
  }
}

// Provider for tapping service
final tappingServiceProvider = Provider<TappingService>((ref) {
  return TappingService(ref);
});
