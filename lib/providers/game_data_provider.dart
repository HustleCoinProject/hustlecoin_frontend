import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/shop_item.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// --- Static game data ---
final allHustlesProvider = FutureProvider<Map<String, Map<String, String>>>((
  ref,
) async {
  return ref.read(dataRepositoryProvider).getAllHustles();
});

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final userState = ref.watch(userControllerProvider);
  final user = userState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
  if (user == null) return [];
  return ref.read(dataRepositoryProvider).getAllTasks();
});

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final userState = ref.watch(userControllerProvider);
  final user = userState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
  if (user == null) return [];
  return ref.read(dataRepositoryProvider).getShopItems();
});
