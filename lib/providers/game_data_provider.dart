import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task.dart';
import '../data/models/shop_item.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

// --- Static game data ---
final allHustlesProvider = FutureProvider<Map<String, Map<String, String>>>((
  ref,
) async {
  return ref.read(apiRepositoryProvider).getAllHustles();
});

final allTasksProvider = FutureProvider<List<Task>>((ref) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getAllTasks();
});

final shopItemsProvider = FutureProvider<List<ShopItem>>((ref) async {
  final user = ref.watch(userControllerProvider);
  if (user.value == null) return [];
  return ref.read(apiRepositoryProvider).getShopItems();
});
