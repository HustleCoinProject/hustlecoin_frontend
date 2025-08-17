import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart'; // Assuming you have this file from the previous steps

// --- Reusable Helper Widgets ---

// High-performance "smoky glass" container without blur
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

// Lightweight press feedback widget
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
        widget.onTap?.call();
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

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // State to track the selected option. null means no option is selected.
  int? _selectedOptionIndex;

  // Hardcoded quiz data for this example
  final String question = 'What is the capital city of Angola?';
  final List<String> options = [
    'A) Lobito',
    'B) Luanda',
    'C) Huambo',
    'D) Benguela',
  ];

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex != null) {
      // Logic to check answer, give rewards, etc.
      print('Submitted answer: ${options[_selectedOptionIndex!]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Taxi Driver.png'),
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
            child: Column(children: [_buildHeader(context), _buildContent()]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // This header is identical to the one in ShopScreen
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        children: [
          PressableWidget(
            onTap: () => Navigator.of(context).pop(),
            child: const _GlassEffectContainer(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: SizedBox(
                width: 54,
                height: 54,
                child: Icon(FontAwesomeIcons.arrowLeft, size: 20),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Daily Quiz',
              textAlign: TextAlign.center,
              style: TextStyle(
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1,250 HC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '≈ Kz 12,507',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
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

  Widget _buildContent() {
    bool isButtonEnabled = _selectedOptionIndex != null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Question Box
            _GlassEffectContainer(
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(20),
              child: Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Options
            ...options.asMap().entries.map((entry) {
              int index = entry.key;
              String optionText = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: _buildOptionCard(optionText, index),
              );
            }),

            const Spacer(), // Pushes the button towards the bottom if there's space
            // Submit Button
            AnimatedOpacity(
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
                  child: const Text(
                    'Submit Answer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
