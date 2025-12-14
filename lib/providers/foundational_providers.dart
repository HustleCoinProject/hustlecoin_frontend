import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/api_repository.dart';
import '../data/repositories/data_repository.dart';
import '../data/cache/cache_manager.dart';
import 'auth_provider.dart';

// --- Foundational Providers ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});

// Cache manager provider
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final cacheManager = CacheManager();
  // Initialize cache manager
  cacheManager.initialize();
  return cacheManager;
});

// API repository provider (internal use by DataRepository)
final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final repo = ApiRepository();
  // Listen to the auth token and update the repository
  final authState = ref.watch(authControllerProvider);
  final tokens = authState.when(
    data: (tokens) => tokens,
    loading: () => null,
    error: (_, __) => null,
  );
  repo.setTokens(tokens?.accessToken, tokens?.refreshToken);

  // Set up token refresh callback
  repo.setOnTokensRefreshed((newTokens) {
    ref.read(authControllerProvider.notifier).updateTokens(newTokens);
  });

  return repo;
}, dependencies: [authControllerProvider]);

// Data repository provider (main repository used by app)
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  final apiRepo = ref.watch(apiRepositoryProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  final dataRepo = DataRepository(apiRepo, cacheManager);

  // Listen to the auth token and update the repository
  final authState = ref.watch(authControllerProvider);
  final tokens = authState.when(
    data: (tokens) => tokens,
    loading: () => null,
    error: (_, __) => null,
  );
  dataRepo.setTokens(tokens?.accessToken, tokens?.refreshToken);

  // Set up token refresh callback
  dataRepo.setOnTokensRefreshed((newTokens) {
    ref.read(authControllerProvider.notifier).updateTokens(newTokens);
  });

  return dataRepo;
}, dependencies: [apiRepositoryProvider, cacheManagerProvider, authControllerProvider]);
