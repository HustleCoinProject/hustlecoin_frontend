import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/utils/localization.dart';

// This is a simple test widget to verify localization is working
class LocalizationTestScreen extends ConsumerWidget {
  const LocalizationTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localization Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Language: $currentLanguage'),
            const SizedBox(height: 20),
            Text('Home: ${ref.t(LocalizationKeys.home)}'),
            Text('Shop: ${ref.t(LocalizationKeys.shop)}'),
            Text('Profile: ${ref.t(LocalizationKeys.profile)}'),
            Text('Daily Tap: ${ref.t(LocalizationKeys.dailyTap)}'),
            Text('Watch Ad: ${ref.t(LocalizationKeys.watchAd)}'),
            Text('Welcome: ${ref.t(LocalizationKeys.welcomeBack)}'),
            Text('Hustle Coin: ${ref.t(LocalizationKeys.hustleCoin)}'),
            Text('Level: ${ref.t(LocalizationKeys.level)}'),
            Text('Error: ${ref.t(LocalizationKeys.error)}'),
            const SizedBox(height: 20),
            const Text(
              'Test completed! Check if the text above is translated based on user language.',
            ),
          ],
        ),
      ),
    );
  }
}
