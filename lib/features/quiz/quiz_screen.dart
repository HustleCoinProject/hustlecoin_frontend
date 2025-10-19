// lib/quiz.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/data/models/quiz_question.dart';
import 'package:hustlecoin/data/models/quiz_result.dart';
import 'package:hustlecoin/providers/quiz_provider.dart';
import 'package:hustlecoin/providers/user_provider.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/utils/ad_helper.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'package:hustlecoin/widgets/screen_header.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizQuestionProvider);
    final user = ref.watch(userControllerProvider).value;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/${user != null ? HustleUtils.getCurrentHustleKey(user.currentHustle) : "Taxi Driver"}.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF101010).withOpacity(0.4),
                const Color(0xFF101010).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: ref.t(LocalizationKeys.dailyQuiz),
                  trailingWidget: GlassContainer(
                    borderRadius: 12,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.angolaRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.star,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user?.hcBalance ?? 0} HC',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '≈ Kz ${user?.kzBalance ?? 0}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: quizAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (quiz) => _QuizContent(quiz: quiz),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizContent extends ConsumerStatefulWidget {
  final QuizQuestion quiz;
  const _QuizContent({required this.quiz});

  @override
  ConsumerState<_QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends ConsumerState<_QuizContent> {
  int? _selectedOptionIndex;

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  // CHANGED: This function is now incredibly simple.
  void _submitAnswer() {
    if (_selectedOptionIndex == null) return;

    // Create the result object
    final result = QuizResult(
      quizId: widget.quiz.quizId,
      answerIndex: _selectedOptionIndex!,
    );

    // Store the result globally (hack)
    globalQuizResult = result;

    // Play earn coins sound when quiz is completed
    SoundService().playEarnCoins();

    // Show interstitial ad after quiz completion
    AdHelper.showInterstitialAfterTask();

    // Pop the screen and pass the result back to HomeScreen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _selectedOptionIndex != null;

    return ResponsiveBuilder(
      builder: (context) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.s),
              child: Column(
                children: [
                  SizedBox(height: 20.s), // Add some top spacing
                  GlassContainer(
                    borderRadius: 16,
                    padding: EdgeInsets.all(20.s),
                    child: Text(
                      widget.quiz.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.f,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 25.s),
                  ...widget.quiz.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String optionText = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.s),
                      child: _buildOptionCard(optionText, index),
                    );
                  }),
                  SizedBox(height: 100.s), // Add space for button
                ],
              ),
            ),
          ),
          // submit button at bottom
          Padding(
            padding: EdgeInsets.all(20.s),
            child: SizedBox(
              width: double.infinity, // Wrap in SizedBox to enforce full width
              child: PrimaryActionButton(
                text: ref.t(LocalizationKeys.submitAnswer),
                onTap: isButtonEnabled ? _submitAnswer : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String text, int index) {
    bool isSelected = _selectedOptionIndex == index;
    return PressableScaleWidget(
      onTap: () => _selectOption(index),
      child: GlassContainer(
        borderRadius: 12,
        padding: const EdgeInsets.all(18),
        border: Border.all(
          color: isSelected ? AppColors.angolaYellow : AppColors.glassBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.glowYellow,
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
              ]
            : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// global quiz result variable
QuizResult? quizResult;
