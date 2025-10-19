import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/api_repository.dart';
import 'auth_provider.dart';

// --- Foundational Providers ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // This will be overridden in main.dart
  throw UnimplementedError();
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final repo = ApiRepository();
  // Listen to the auth token and update the repository
  final authState = ref.watch(authControllerProvider);
  final tokens = authState.when(
    data: (tokens) => tokens,
    loading: () => null,
    error: (_, __) => null,
  );
  print(
    "DEBUG: apiRepositoryProvider - Setting tokens: ${tokens != null ? 'YES' : 'NO'}",
  );
  repo.setTokens(tokens?.accessToken, tokens?.refreshToken);

  // Set up token refresh callback
  repo.setOnTokensRefreshed((newTokens) {
    ref.read(authControllerProvider.notifier).updateTokens(newTokens);
  });

  return repo;
}, dependencies: [authControllerProvider]);
