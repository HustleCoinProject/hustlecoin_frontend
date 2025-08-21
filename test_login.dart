import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/state/all_states.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  print("Testing auth state after initialization...");

  // Wait a moment and check the state
  await Future.delayed(Duration(seconds: 2));

  final authState = container.read(authControllerProvider);
  final userState = container.read(userControllerProvider);

  print("Auth state: ${authState.value != null ? 'HAS_TOKEN' : 'NO_TOKEN'}");
  print(
    "User state: ${userState.when(data: (user) => user != null ? 'HAS_USER(${user.username})' : 'NO_USER', loading: () => 'LOADING', error: (e, _) => 'ERROR: $e')}",
  );

  container.dispose();
}
