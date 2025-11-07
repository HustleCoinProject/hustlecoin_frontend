import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/land_tile_info.dart';
import '../data/models/my_land_tiles.dart';
import '../data/models/land_claim_status.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// --- Land System Providers ---

final landTilesProvider = FutureProvider.family
    .autoDispose<List<LandTileInfo>, String>((ref, bbox) async {
      final user = ref.watch(userControllerProvider);
      if (user.value == null) return [];

      final api = ref.read(apiRepositoryProvider);
      return api.getTilesInBbox(bbox);
    });

final myLandsProvider = FutureProvider.autoDispose<List<MyLandTile>>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];

  final api = ref.read(apiRepositoryProvider);
  return api.getMyLands();
});

// --- Land Income Claim Providers ---

final landClaimStatusProvider = FutureProvider.autoDispose<LandClaimStatus?>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return null;

  final api = ref.read(apiRepositoryProvider);
  try {
    return await api.getLandClaimStatus();
  } catch (e) {
    // If user has no land, return null instead of throwing
    if (e.toString().contains('don\'t own any land')) {
      return null;
    }
    rethrow;
  }
});
