import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hustlecoin/features/auth/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hustlecoin/features/home/home_screen.dart';

import 'package:hustlecoin/providers/auth_provider.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/providers/time_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/providers/tapping_status_provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hustlecoin/services/admob_service.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/responsive_theme.dart';
import 'package:hustlecoin/utils/admob_debug_helper.dart';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

// We need to initialize the server time sync after the app starts
// Create a StatefulWidget that will synchronize with server on initialization
class ServerTimeInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const ServerTimeInitializer({super.key, required this.child});

  @override
  ConsumerState<ServerTimeInitializer> createState() =>
      _ServerTimeInitializerState();
}

class _ServerTimeInitializerState extends ConsumerState<ServerTimeInitializer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    WidgetsBinding.instance.addObserver(this);

    // Schedule server time sync after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize server time sync
      ref.read(serverTimeProvider.notifier).syncWithServer();

      // Initialize tapping status - this will fetch from /tapping/status endpoint
      ref.read(tappingStatusProvider);

      // Show app open ad on first launch
      _showAppOpenAdIfAvailable();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Show app open ad when app comes to foreground
      _showAppOpenAdIfAvailable();
    }
  }

  void _showAppOpenAdIfAvailable() {
    final adMobService = AdMobService();

    // Only show if we haven't shown one yet or if cooldown has passed
    if (adMobService.canShowAppOpenAd && adMobService.isAppOpenAdLoaded) {
      print('DEBUG: ServerTimeInitializer - Showing app open ad');
      adMobService.showAppOpenAd().then((shown) {
        if (shown) {
          print(
            'DEBUG: ServerTimeInitializer - App open ad shown successfully',
          );
        } else {
          print('DEBUG: ServerTimeInitializer - Failed to show app open ad');
        }
      });
    } else {
      print(
        'DEBUG: ServerTimeInitializer - App open ad not available (cooldown: ${!adMobService.canShowAppOpenAd}, loaded: ${adMobService.isAppOpenAdLoaded})',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: main() - Flutter bindings initialized');

  // Initialize Firebase
  print('DEBUG: main() - Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('DEBUG: main() - ✅ Firebase initialized successfully');
  } catch (e) {
    print('DEBUG: main() - ❌ Failed to initialize Firebase: $e');
  }

  // Initialize Hive for caching
  print('DEBUG: main() - Initializing Hive...');
  await Hive.initFlutter();
  print('DEBUG: main() - ✅ Hive initialized successfully');

  // Initialize Google Mobile Ads SDK
  print('DEBUG: main() - Initializing Google Mobile Ads SDK...');
  try {
    await MobileAds.instance.initialize();
    print('DEBUG: main() - ✅ Google Mobile Ads SDK initialized successfully');
  } catch (e) {
    print('DEBUG: main() - ❌ Failed to initialize Google Mobile Ads SDK: $e');
  }

  // Validate AdMob configuration
  AdMobService.validateAdConfiguration();
  
  // Print AdMob diagnostics
  AdMobDebugHelper.printAdMobDiagnostics();

  // Initialize AdMob service and preload ads
  print('DEBUG: main() - Creating AdMob service instance...');
  final adMobService = AdMobService();
  print('DEBUG: main() - AdMob service created, loading ads...');

  try {
    // Load all ad types
    print('DEBUG: main() - Loading rewarded ad...');
    await adMobService.loadRewardedAd();
    print('DEBUG: main() - ✅ Rewarded ad load attempt completed');
    print(
      'DEBUG: main() - Rewarded ad loaded state: ${adMobService.isRewardedAdLoaded}',
    );

    print('DEBUG: main() - Loading interstitial ad...');
    await adMobService.loadInterstitialAd();
    print('DEBUG: main() - ✅ Interstitial ad load attempt completed');
    print(
      'DEBUG: main() - Interstitial ad loaded state: ${adMobService.isInterstitialAdLoaded}',
    );

    print('DEBUG: main() - Loading app open ad...');
    await adMobService.loadAppOpenAd();
    print('DEBUG: main() - ✅ App open ad load attempt completed');
    print(
      'DEBUG: main() - App open ad loaded state: ${adMobService.isAppOpenAdLoaded}',
    );
  } catch (e) {
    print('DEBUG: main() - ❌ Failed to load some ads: $e');
  }

  // Get SharedPreferences instance
  print('DEBUG: main() - Getting SharedPreferences instance...');
  final prefs = await SharedPreferences.getInstance();

  // Initialize sound service
  print('DEBUG: main() - Initializing sound service...');
  await SoundService().initialize();
  print('DEBUG: main() - ✅ Sound service initialized');

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
    return ResponsiveBuilder(
      builder: (context) => MaterialApp(
        title: 'Hustle Coin',
        theme: ResponsiveTheme.buildTheme(context),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state
    final authState = ref.watch(authControllerProvider);
    // Watch the user state
    final userState = ref.watch(userControllerProvider);

    final hasTokens = authState.when(
      data: (tokens) => tokens != null,
      loading: () => false,
      error: (_, __) => false,
    );
    print(
      "DEBUG: AuthWrapper - authState: ${hasTokens ? 'HAS_TOKENS' : 'NO_TOKENS'}",
    );
    print(
      "DEBUG: AuthWrapper - userState: ${userState.when(data: (user) => user != null ? 'HAS_USER(${user.username})' : 'NO_USER', loading: () => 'LOADING', error: (e, _) => 'ERROR: $e')}",
    );

    return userState.when(
      data: (user) {
        // If user object is not null, they are logged in.
        if (user != null) {
          print(
            "DEBUG: AuthWrapper - Navigating to HomeScreen for user: ${user.username}",
          );
          return const HomeScreen();
        }
        // Otherwise, show the start/login screen.
        print("DEBUG: AuthWrapper - Navigating to StartScreen (no user)");
        return const StartScreen();
      },
      // Show a loading screen while checking auth state
      loading: () {
        print("DEBUG: AuthWrapper - Showing loading screen");
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      // Show an error screen if something goes wrong
      error: (error, stack) {
        print("DEBUG: AuthWrapper - Showing error screen: $error");
        return Scaffold(body: Center(child: Text('An error occurred: $error')));
      },
    );
  }
}
