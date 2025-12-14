import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/level_status.dart';
import '../data/models/inventory_item_out.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// --- User-specific data that can be refreshed ---

final availableHustlesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
      final userState = ref.watch(userControllerProvider);
      final user = userState.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );
      if (user == null) return <String, String>{};
      return ref.read(dataRepositoryProvider).getAvailableHustles();
    });

final levelStatusProvider = FutureProvider.autoDispose<LevelStatus?>((ref) async {
  final userState = ref.watch(userControllerProvider);
  final user = userState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
  if (user == null) return null;
  return ref.read(dataRepositoryProvider).getLevelStatus();
});

final inventoryProvider = FutureProvider.autoDispose<List<InventoryItemOut>>((
  ref,
) async {
  final userState = ref.watch(userControllerProvider);
  final user = userState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
  
  if (user == null) {
    return [];
  }
  
  try {
    final inventory = await ref.read(dataRepositoryProvider).getInventory();
    return inventory;
  } catch (e) {
    rethrow;
  }
});
