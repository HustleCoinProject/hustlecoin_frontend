import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/home_screen.dart';
import 'app_colors.dart';
import 'state/all_states.dart';

class SelectHustleScreen extends ConsumerStatefulWidget {
  final int newLevel;
  final String newHustle;

  const SelectHustleScreen({
    Key? key,
    required this.newLevel,
    required this.newHustle,
  }) : super(key: key);

  @override
  ConsumerState<SelectHustleScreen> createState() => _SelectHustleScreenState();
}

class _SelectHustleScreenState extends ConsumerState<SelectHustleScreen> {
  // Controller for the hustle carousel PageView
  late final PageController _hustleController;

  int _selectedHustleIndex = 0;
  List<Map<String, String>> _availableHustles = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _hustleController = PageController(viewportFraction: 0.8)
      ..addListener(() {
        setState(() {
          // Update the index when the page settles
          if (_hustleController.page != null &&
              _hustleController.page!.round() != _selectedHustleIndex) {
            _selectedHustleIndex = _hustleController.page!.round();
          }
        });
      });

    // Fetch available hustles for the new level
    _fetchAvailableHustles();
  }

  Future<void> _fetchAvailableHustles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiRepo = ref.read(apiRepositoryProvider);
      final availableHustles = await apiRepo.getAvailableHustles();

      setState(() {
        _availableHustles = availableHustles
            .map((name) => {'name': name, 'image': 'assets/images/$name.png'})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load available hustles: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmHustleSelection() async {
    if (_availableHustles.isEmpty) {
      setState(() {
        _errorMessage = 'No hustles available to select';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    // Get the selected hustle
    final selectedHustle =
        _availableHustles[_selectedHustleIndex]['name'] ?? '';

    try {
      final apiRepo = ref.read(apiRepositoryProvider);

      // Make the API call to select the hustle
      await apiRepo.selectHustle(selectedHustle);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully selected $selectedHustle as your new hustle!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Reset submitting state before navigation
        setState(() {
          _isSubmitting = false;
        });

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to select hustle: $e';
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _hustleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/${widget.newHustle}.png'),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Show error message if any
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.6),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Congratulations header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.angolaYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.angolaYellow.withOpacity(0.6),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎉 CONGRATULATIONS! 🎉',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.angolaYellow,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'ve been promoted to Level ${widget.newLevel}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Choose Your New Hustle',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select a hustle to reflect your new status',
                      style: TextStyle(fontSize: 16, color: AppColors.textGrey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Hustle carousel
                    if (_isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.angolaYellow,
                        ),
                      )
                    else if (_availableHustles.isEmpty)
                      const Text(
                        'No hustles available. Please try again later.',
                        style: TextStyle(color: AppColors.textGrey),
                        textAlign: TextAlign.center,
                      )
                    else
                      SizedBox(
                        height: 350, // Give the carousel a fixed height
                        child: PageView.builder(
                          controller: _hustleController,
                          itemCount: _availableHustles.length,
                          itemBuilder: (context, index) {
                            return _buildHustleCard(index);
                          },
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Confirm button
                    PressableWidget(
                      onTap: (_isLoading || _isSubmitting)
                          ? null
                          : _confirmHustleSelection,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.angolaYellow,
                              AppColors.angolaRed,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: _isSubmitting
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Text(
                                'Confirm Selection',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHustleCard(int index) {
    bool isSelected = index == _selectedHustleIndex;
    final hustle = _availableHustles[index];

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.angolaYellow : Colors.transparent,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow,
                      blurRadius: 25,
                      spreadRadius: -5,
                    ),
                  ]
                : [],
          ),
          child: _GlassEffectContainer(
            borderRadius: BorderRadius.circular(
              17,
            ), // Slightly smaller to show border
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Uri.parse(hustle['image']!).isAbsolute
                        ? Image.network(
                            hustle['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Image.asset(
                            hustle['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  hustle['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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

// HIGH-PERFORMANCE VERSION: No blur, just a semi-transparent container.
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}
