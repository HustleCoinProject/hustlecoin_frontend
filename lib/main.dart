import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start.dart';
import 'app_colors.dart';

import 'package:hustlecoin/home_screen.dart';

import 'package:hustlecoin/state/all_states.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        // Override the unimplemented provider with the actual instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hustle Coin',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.angolaBlack,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user state
    final userState = ref.watch(userControllerProvider);

    return userState.when(
      data: (user) {
        // If user object is not null, they are logged in.
        if (user != null) {
          return const HomeScreen();
        }
        // Otherwise, show the start/login screen.
        return const StartScreen();
      },
      // Show a loading screen while checking auth state
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Show an error screen if something goes wrong
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('An error occurred: $error'))),
    );
  }
}
