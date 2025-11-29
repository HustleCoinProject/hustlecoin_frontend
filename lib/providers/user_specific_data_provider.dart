import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/level_status.dart';
import '../data/models/inventory_item_out.dart';
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

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItemOut>>((
  ref,
) async {
  print('DEBUG: inventoryProvider called');
  final user = ref.watch(userControllerProvider);
  print('DEBUG: inventoryProvider - user state: ${user.when(
    data: (u) => u != null ? 'loaded (${u.username})' : 'null', 
    loading: () => 'loading', 
    error: (e, _) => 'error: $e'
  )}');
  
  if (user.value == null) {
    print('DEBUG: inventoryProvider - user is null, returning empty list');
    return [];
  }
  
  try {
    print('DEBUG: inventoryProvider - fetching inventory...');
    final inventory = await ref.read(apiRepositoryProvider).getInventory();
    print('DEBUG: inventoryProvider - fetched ${inventory.length} items');
    return inventory;
  } catch (e) {
    print('DEBUG: inventoryProvider - error fetching inventory: $e');
    rethrow;
  }
});
