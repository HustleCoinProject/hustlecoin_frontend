import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start.dart';
import 'app_colors.dart';

import 'package:hustlecoin/home_screen.dart';

import 'package:hustlecoin/state/all_states.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

// We need to initialize the server time sync after the app starts
// Create a StatefulWidget that will synchronize with server on initialization
class ServerTimeInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const ServerTimeInitializer({super.key, required this.child});

  @override
  ConsumerState<ServerTimeInitializer> createState() =>
      _ServerTimeInitializerState();
}

class _ServerTimeInitializerState extends ConsumerState<ServerTimeInitializer> {
  @override
  void initState() {
    super.initState();
    // Schedule server time sync after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize server time sync
      ref.read(serverTimeProvider.notifier).syncWithServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();

  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Start the app with a single ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        // Override the unimplemented provider with the actual instance
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ServerTimeInitializer(child: MyApp()),
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
