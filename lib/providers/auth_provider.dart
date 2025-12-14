import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/auth_tokens.dart';
import '../data/repositories/api_repository.dart';
import '../data/repositories/data_repository.dart';
import '../data/cache/cache_manager.dart';
import '../services/firebase_auth_service.dart';
import 'foundational_providers.dart';

// --- Authentication State ---

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthTokens?>>((ref) {
      return AuthController(
        ref.watch(sharedPreferencesProvider),
        FirebaseAuthService(),
      );
    });

class AuthController extends StateNotifier<AsyncValue<AuthTokens?>> {
  final SharedPreferences _prefs;
  final FirebaseAuthService _firebaseAuthService;
  
  AuthController(this._prefs, this._firebaseAuthService)
      : super(const AsyncValue.loading()) {
    _tryAutoLogin();
  }

  static const _tokensKey = 'authTokens';

  void _tryAutoLogin() {
    final tokensJson = _prefs.getString(_tokensKey);
    AuthTokens? tokens;
    if (tokensJson != null) {
      try {
        tokens = AuthTokens.fromJson(json.decode(tokensJson));
      } catch (e) {
        print("DEBUG: Failed to parse stored tokens: $e");
      }
    }

    print(
      "DEBUG: AuthController _tryAutoLogin - found tokens: ${tokens != null ? 'YES' : 'NO'}",
    );
    state = AsyncValue.data(tokens);
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      // Temporarily create a repository to perform login
      final tempRepo = DataRepository(ApiRepository(), CacheManager());
      final tokens = await tempRepo.login(username, password);
      await _prefs.setString(_tokensKey, json.encode(tokens.toJson()));
      state = AsyncValue.data(tokens);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign in with Google using Firebase
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // Sign in with Google and get Firebase ID token
      final firebaseIdToken = await _firebaseAuthService.signInWithGoogle();

      // Send the Firebase ID token to backend for verification
      final tempRepo = DataRepository(ApiRepository(), CacheManager());
      final tokens = await tempRepo.loginWithFirebase(firebaseIdToken);
      
      await _prefs.setString(_tokensKey, json.encode(tokens.toJson()));
      state = AsyncValue.data(tokens);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      await _firebaseAuthService.signOut();
    }
  }

  Future<void> updateTokens(AuthTokens newTokens) async {
    try {
      await _prefs.setString(_tokensKey, json.encode(newTokens.toJson()));
      state = AsyncValue.data(newTokens);
      print("DEBUG: Tokens updated successfully");
    } catch (e) {
      print("DEBUG: Failed to update tokens: $e");
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokensKey);
    // Sign out from Firebase/Google if user was signed in via Google
    await _firebaseAuthService.signOut();
    state = const AsyncValue.data(null);
  }
}
