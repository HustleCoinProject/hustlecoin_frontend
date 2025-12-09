import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/user.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/screen_background.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 30),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.when(
      data: (user) => user,
      loading: () => null,
      error: (_, __) => null,
    );

    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath:
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.jpg',
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: ref.t(LocalizationKeys.credits).toUpperCase(),
                  showBackButton: true,
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: ResponsiveUtils.pSymmetric(
                        horizontal: 15.0,
                        vertical: 20.0,
                      ),
                      child: GlassContainer(
                        borderRadius: 20,
                        padding: ResponsiveUtils.pSymmetric(
                          horizontal: 100.0,
                          vertical: 40.0,
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCreditLine('💡'),
                              SizedBox(height: 20.s),
                              _buildCreditLine('Ailton Walter', large: true),
                              SizedBox(height: 8.s),
                              _buildCreditLine(ref.t(LocalizationKeys.founderVisionary)),
                              SizedBox(height: 40.s),
                              _buildCreditLine('⭐'),
                              SizedBox(height: 40.s),
                              _buildCreditLine('💻'),
                              SizedBox(height: 20.s),
                              _buildCreditLine('Mujtaba', large: true),
                              SizedBox(height: 8.s),
                              _buildCreditLine(ref.t(LocalizationKeys.leadDeveloper)),
                              SizedBox(height: 40.s),
                              _buildCreditLine('✨'),
                              SizedBox(height: 40.s),
                              _buildCreditLine('🎨'),
                              SizedBox(height: 20.s),
                              _buildCreditLine('Flutter & Dart'),
                              SizedBox(height: 40.s),
                              _buildCreditLine('🎵'),
                              SizedBox(height: 20.s),
                              _buildCreditLine('Sound Effects'),
                              SizedBox(height: 40.s),
                              _buildCreditLine('🔧'),
                              SizedBox(height: 20.s),
                              _buildCreditLine('Font Awesome'),
                              SizedBox(height: 60.s),
                              _buildCreditLine('❤️', large: true),
                              SizedBox(height: 20.s),
                              _buildCreditLine(ref.t(LocalizationKeys.madeWithLove)),
                              SizedBox(height: 100.s),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditLine(String text, {bool large = false}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: large ? 24.f : 16.f,
        fontWeight: large ? FontWeight.w700 : FontWeight.w500,
        color: AppColors.textLight,
        letterSpacing: large ? 1.5 : 1,
        shadows: [
          Shadow(
            color: AppColors.angolaYellow.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}