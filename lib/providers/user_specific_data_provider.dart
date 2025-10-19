import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/level_status.dart';
import '../data/models/inventory_item.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// --- User-specific data that can be refreshed ---

final availableHustlesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
      final user = ref.watch(userControllerProvider);
      if (user.value == null) return <String, String>{};
      return ref.read(apiRepositoryProvider).getAvailableHustles();
    });

final levelStatusProvider = FutureProvider.autoDispose<LevelStatus?>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return null;
  return ref.read(apiRepositoryProvider).getLevelStatus();
});

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItem>>((
  ref,
) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getInventory();
});
