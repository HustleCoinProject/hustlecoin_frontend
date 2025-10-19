import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/providers/foundational_providers.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/primary_action_button.dart';
import 'package:hustlecoin/widgets/screen_background.dart';

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
  List<Map<String, String>> _availableHustles =
      []; // Changed to store key-value pairs
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
        _availableHustles = availableHustles.entries
            .map(
              (entry) => {
                'key': entry.key, // English name (for images and API calls)
                'name': entry.value, // Localized name (for display)
                'image':
                    'assets/images/${entry.key}.png', // Use key for image path
              },
            )
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

    // Get the selected hustle key (English name for API)
    final selectedHustleKey =
        _availableHustles[_selectedHustleIndex]['key'] ?? '';
    final selectedHustleName =
        _availableHustles[_selectedHustleIndex]['name'] ?? '';

    try {
      final apiRepo = ref.read(apiRepositoryProvider);

      // Make the API call to select the hustle using the key
      await apiRepo.selectHustle(selectedHustleKey);

      // Show success message with the display name
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully selected $selectedHustleName as your new hustle!',
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
    return ResponsiveBuilder(
      builder: (context) => Scaffold(
        body: ScreenBackground(
          imagePath: 'assets/images/${widget.newHustle}.png',
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: ResponsiveUtils.pSymmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Show error message if any
                    if (_errorMessage != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 20.s),
                        padding: ResponsiveUtils.pSymmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.6),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.white, fontSize: 14.f),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Congratulations header
                    Container(
                      padding: ResponsiveUtils.pSymmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.angolaYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.angolaYellow.withOpacity(0.6),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🎉 CONGRATULATIONS! 🎉',
                            style: TextStyle(
                              fontSize: 20.f,
                              fontWeight: FontWeight.w700,
                              color: AppColors.angolaYellow,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.s),
                          Text(
                            'You\'ve been promoted to Level ${widget.newLevel}',
                            style: TextStyle(
                              fontSize: 16.f,
                              color: AppColors.textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.s),
                    Text(
                      'Choose Your New Hustle',
                      style: TextStyle(
                        fontSize: 28.f,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10.s),
                    Text(
                      'Select a hustle to reflect your new status',
                      style: TextStyle(
                        fontSize: 16.f,
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.s),

                    // Hustle carousel
                    if (_isLoading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.angolaYellow,
                        ),
                      )
                    else if (_availableHustles.isEmpty)
                      Text(
                        'No hustles available. Please try again later.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14.f,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      SizedBox(
                        height: 350.s, // Give the carousel a fixed height
                        child: PageView.builder(
                          controller: _hustleController,
                          itemCount: _availableHustles.length,
                          itemBuilder: (context, index) {
                            return _buildHustleCard(index);
                          },
                        ),
                      ),

                    SizedBox(height: 30.s),

                    // Confirm button
                    SizedBox(
                      width: double
                          .infinity, // Wrap in SizedBox to enforce full width
                      child: PrimaryActionButton(
                        text: 'Confirm Selection',
                        onTap: _confirmHustleSelection,
                        isLoading: _isSubmitting,
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
          margin: ResponsiveUtils.pSymmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? AppColors.angolaYellow : Colors.transparent,
              width: 3.s,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.glowYellow,
                      blurRadius: 25.s,
                      spreadRadius: -5.s,
                    ),
                  ]
                : [],
          ),
          child: GlassContainer(
            borderRadius: 17,
            padding: EdgeInsets.all(20.s),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
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
                SizedBox(height: 15.s),
                Text(
                  hustle['name']!,
                  style: TextStyle(fontSize: 18.f, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
