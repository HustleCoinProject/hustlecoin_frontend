// lib/quiz.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hustlecoin/state/all_states.dart';
import 'package:hustlecoin/services/sound_service.dart';
import 'package:hustlecoin/utils/ad_helper.dart';
import 'package:hustlecoin/utils/hustle_utils.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'app_colors.dart';

// --- Reusable Helper Widgets (copied from your original for completeness) ---

class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.padding = EdgeInsets.zero,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius,
        border: border ?? Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow:
            boxShadow ??
            [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
      ),
      child: child,
    );
  }
}

class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const PressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.97,
  });

  @override
  State<PressableWidget> createState() => _PressableWidgetState();
}

class _PressableWidgetState extends State<PressableWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) {
          // Play click sound before calling onTap
          SoundService().playClick();
          widget.onTap!.call();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// --- Main Quiz Screen Widget ---

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
                _buildHeader(context, ref),
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider).value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          PressableWidget(
            onTap: () => Navigator.of(context).pop(), // Pop without a result
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Text(
              ref.t(LocalizationKeys.dailyQuiz),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ),
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
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
        ],
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20), // Add some top spacing
                _GlassEffectContainer(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.quiz.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ...widget.quiz.options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String optionText = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: _buildOptionCard(optionText, index),
                  );
                }),
                const SizedBox(height: 100), // Add space for button
              ],
            ),
          ),
        ),
        // Fixed submit button at bottom
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AnimatedOpacity(
            opacity: isButtonEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: PressableWidget(
              onTap: isButtonEnabled ? _submitAnswer : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.angolaYellow, AppColors.angolaRed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  ref.t(LocalizationKeys.submitAnswer),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(String text, int index) {
    bool isSelected = _selectedOptionIndex == index;
    return PressableWidget(
      onTap: () => _selectOption(index),
      child: _GlassEffectContainer(
        borderRadius: BorderRadius.circular(12),
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
