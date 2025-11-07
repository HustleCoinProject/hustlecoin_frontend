import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/land_claim_status.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

/// A provider that provides real-time countdown updates for land claim status
/// This provider updates every second to provide smooth countdown experience
final landClaimCountdownProvider = StreamProvider.autoDispose<LandClaimStatus?>(
  (ref) async* {
    final user = ref.watch(userControllerProvider);
    if (user.value == null) {
      yield null;
      return;
    }

    final api = ref.read(apiRepositoryProvider);

    // Initial fetch
    LandClaimStatus? currentStatus;
    try {
      currentStatus = await api.getLandClaimStatus();
    } catch (e) {
      // If user has no land, return null instead of throwing
      if (e.toString().contains('don\'t own any land')) {
        yield null;
        return;
      }
      rethrow;
    }

    yield currentStatus;

    // If there's a countdown active, start a timer to update it
    if (currentStatus.timeUntilNextClaimSeconds != null &&
        currentStatus.timeUntilNextClaimSeconds! > 0) {
      int remainingSeconds = currentStatus.timeUntilNextClaimSeconds!;
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        remainingSeconds--;

        if (remainingSeconds <= 0) {
          timer.cancel();
          // When countdown reaches 0, we need to refresh from server
          // The provider will naturally refresh due to auto dispose
          return;
        }

        // Emit updated status with new countdown
        final updatedStatus = LandClaimStatus(
          canClaim: false, // Still on cooldown
          availableIncome: currentStatus!.availableIncome,
          tilesCount: currentStatus!.tilesCount,
          lastClaimAt: currentStatus!.lastClaimAt,
          nextClaimAvailableAt: currentStatus!.nextClaimAvailableAt,
          timeUntilNextClaimSeconds: remainingSeconds,
        );

        // Update the currentStatus reference for next iteration
        currentStatus = updatedStatus;
      });

      // Clean up timer when provider is disposed
      ref.onDispose(() {
        timer.cancel();
      });

      // Continue streaming updated countdown values
      await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
        if (remainingSeconds <= 0) break;

        yield LandClaimStatus(
          canClaim: false,
          availableIncome: currentStatus!.availableIncome,
          tilesCount: currentStatus!.tilesCount,
          lastClaimAt: currentStatus!.lastClaimAt,
          nextClaimAvailableAt: currentStatus!.nextClaimAvailableAt,
          timeUntilNextClaimSeconds: remainingSeconds,
        );
      }

      // When countdown finishes, fetch fresh status from server
      try {
        final freshStatus = await api.getLandClaimStatus();
        yield freshStatus;
      } catch (e) {
        if (e.toString().contains('don\'t own any land')) {
          yield null;
        } else {
          rethrow;
        }
      }
    }
  },
);
