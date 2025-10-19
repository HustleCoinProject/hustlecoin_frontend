import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/land_tile_info.dart';
import '../data/models/my_land_tiles.dart';
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
