import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/app_config.dart';
import 'package:hustlecoin/features/update/update_dialog.dart';
import 'package:hustlecoin/features/update/update_screen.dart';
import 'package:hustlecoin/services/version_check_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hustlecoin/features/auth/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hustlecoin/features/home/home_screen.dart';
import 'package:hustlecoin/widgets/global_reward_listener.dart';

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
import 'package:hustlecoin/services/remote_config_service.dart';

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

      // Check for updates
      _checkVersion();

      // Show app open ad on first launch
      _showAppOpenAdIfAvailable();
    });
  }

  void _checkVersion() {
    final remoteConfig = RemoteConfigService.instance;
    final remoteVersion = remoteConfig.getRemoteAppVersion();
    final localVersion = AppConfig.localAppVersion;

    final status = VersionCheckService.checkVersion(
      localVersion,
      remoteVersion,
    );

    if (status == VersionStatus.forcedUpdate) {
      // Navigate to UpdateRequiredScreen and remove all other routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const UpdateRequiredScreen()),
        (route) => false,
      );
    } else if (status == VersionStatus.optionalUpdate) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const UpdateDialog(),
      );
    }
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
      // Fetch latest remote config and check for updates
      _fetchConfigAndCheckVersion();

      // Show app open ad when app comes to foreground
      _showAppOpenAdIfAvailable();
    }
  }

  Future<void> _fetchConfigAndCheckVersion() async {
    await RemoteConfigService.instance.fetchAndActivate();
    if (mounted) {
      _checkVersion();
    }
  }

  void _showAppOpenAdIfAvailable() {
    final adMobService = AdMobService();

    // Only show if we haven't shown one yet or if cooldown has passed
    if (adMobService.canShowAppOpenAd && adMobService.isAppOpenAdLoaded) {
      adMobService.showAppOpenAd().then((shown) {
        if (shown) {
        } else {}
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}

  // Initialize Hive for caching
  await Hive.initFlutter();

  // Initialize Google Mobile Ads SDK
  try {
    await MobileAds.instance.initialize();
  } catch (e) {}

  // Validate AdMob configuration
  AdMobService.validateAdConfiguration();

  // Print AdMob diagnostics
  AdMobDebugHelper.printAdMobDiagnostics();

  // Initialize AdMob service and preload ads
  final adMobService = AdMobService();

  try {
    // Load all ad types
    await adMobService.loadRewardedAd();
    await adMobService.loadInterstitialAd();
    await adMobService.loadAppOpenAd();
  } catch (e) {}

  // Get SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // Initialize sound service
  await SoundService().initialize();

  // Initialize Remote Config Service
  await RemoteConfigService.instance.initialize();

  // Initialize App Config (Load Version)
  await AppConfig.init();

  // Start the app with a single ProviderScope
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
    return ResponsiveBuilder(
      builder: (context) => MaterialApp(
        title: 'Hustle Points',
        theme: ResponsiveTheme.buildTheme(context),
        home: const ServerTimeInitializer(
          child: GlobalRewardListener(child: AuthWrapper()),
        ),
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
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      // Show an error screen if something goes wrong
      error: (error, stack) {
        return Scaffold(body: Center(child: Text('An error occurred: $error')));
      },
    );
  }
}
