import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'app_colors.dart';

// A custom, lightweight widget for press feedback.
class PressableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final BorderRadius borderRadius;

  const PressableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.borderRadius = BorderRadius.zero,
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeNavIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _activeNavIndex = index;
    });
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
            child: Column(
              children: [
                _buildTopBar(),
                const Text(
                  'Hustle Coin',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                  ),
                ),
                Expanded(child: _buildGameArea()),
                _buildUpgradesSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.angolaRed,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.glowRed,
                          blurRadius: 8,
                          spreadRadius: -2,
                        ),
                      ],
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
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '≈ Kz 12,507',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.angolaYellow, AppColors.angolaRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _GlassEffectContainer(
              borderRadius: BorderRadius.circular(13),
              child: const Icon(FontAwesomeIcons.user, size: 28),
            ),
          ),
          _GlassEffectContainer(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.angolaYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EN',
                      style: TextStyle(
                        color: AppColors.angolaBlack,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      'PT',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: _buildStatsContainer(),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(FontAwesomeIcons.handPointer, 'Daily Tap'),
                  const SizedBox(height: 15),
                  _actionButton(FontAwesomeIcons.circlePlay, 'Watch Ad'),
                  const SizedBox(height: 15),
                  _actionButton(FontAwesomeIcons.brain, 'Quiz'),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(FontAwesomeIcons.mapMarkedAlt, 'Land'),
                  const SizedBox(height: 15),
                  _actionButton(FontAwesomeIcons.calendarAlt, 'Events'),
                ],
              ),
            ),
          ),
          PressableWidget(
            onTap: () {},
            borderRadius: BorderRadius.circular(80),
            child: _GlassEffectContainer(
              isCircle: true,
              child: SizedBox(
                width: 160,
                height: 160,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.coins,
                      size: 50,
                      color: AppColors.angolaYellow,
                      shadows: [
                        Shadow(
                          color: AppColors.glowYellow.withOpacity(0.8),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'TAP',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContainer() {
    const textShadow = [
      Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(1, 1)),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HUSTLE LEVEL',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              const Text(
                'Taxi Driver',
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  shadows: textShadow,
                ),
              ),
              const Text(
                'Level 8',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🔥 Daily Streak',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w600,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'NEXT LEVEL',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 4),
              _GlassEffectContainer(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 1500 / 2500,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.angolaYellow,
                      ),
                      minHeight: 12,
                      color: AppColors.angolaRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1500 / 2500 HC',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                  shadows: textShadow,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: PressableWidget(
                      onTap: () {},
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: AppColors.orange,
                          disabledForegroundColor: AppColors.angolaBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        child: const Text('500 HC'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Upgrade Level',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      shadows: textShadow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return PressableWidget(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: _GlassEffectContainer(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(icon, size: 24, color: AppColors.textGrey),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          _upgradeItem(FontAwesomeIcons.robot, 'Chat bot'),
          const SizedBox(width: 8),
          _upgradeItem(FontAwesomeIcons.rocket, 'Boosts'),
          const SizedBox(width: 8),
          _upgradeItem(FontAwesomeIcons.key, 'Keys'),
          const SizedBox(width: 8),
          _upgradeItem(FontAwesomeIcons.store, 'Shop', isShop: true),
        ],
      ),
    );
  }

  Widget _upgradeItem(IconData icon, String label, {bool isShop = false}) {
    Widget content;
    if (isShop) {
      content = Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppColors.angolaYellow, AppColors.angolaRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.glowRed,
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: _upgradeItemContent(icon, label, AppColors.textLight),
      );
    } else {
      content = _GlassEffectContainer(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 65,
          child: _upgradeItemContent(icon, label, AppColors.textGrey),
        ),
      );
    }
    return Expanded(
      child: PressableWidget(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }

  Widget _upgradeItemContent(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return _GlassEffectContainer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(FontAwesomeIcons.house, 'Home', 0),
            _navItem(FontAwesomeIcons.chartLine, 'Stats', 1),
            _navItem(FontAwesomeIcons.userCircle, 'Profile', 2),
            _navItem(FontAwesomeIcons.cog, 'Settings', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isActive = _activeNavIndex == index;
    final color = isActive ? AppColors.angolaYellow : AppColors.textGrey;
    final shadows = isActive
        ? [const Shadow(color: AppColors.glowYellow, blurRadius: 10)]
        : <Shadow>[];
    return PressableWidget(
      onTap: () => _onNavItemTapped(index),
      borderRadius: BorderRadius.circular(8),
      scaleFactor: 1.1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 22, color: color, shadows: shadows),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: color,
                shadows: shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HIGH-PERFORMANCE VERSION: No blur, just a semi-transparent container.
class _GlassEffectContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const _GlassEffectContainer({
    required this.child,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : borderRadius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}
