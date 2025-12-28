import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/task.dart';
import 'package:hustlecoin/data/repositories/data_repository.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/ad_helper.dart';

class BalloonPopGameScreen extends ConsumerStatefulWidget {
  final Task? rewardTask;
  final DataRepository? dataRepository;

  const BalloonPopGameScreen({super.key, this.rewardTask, this.dataRepository});

  @override
  ConsumerState<BalloonPopGameScreen> createState() =>
      _BalloonPopGameScreenState();
}

class _BalloonPopGameScreenState extends ConsumerState<BalloonPopGameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Game Config
  static const int targetScore = 50;
  static const int initialLives = 3;
  static const double spawnRate = 0.015; // Chance per tick to spawn

  // Game State
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;
  int _lives = initialLives;
  String _endGameMessage = "";

  // Entities
  final List<Balloon> _balloons = [];
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _lives = initialLives;
      _balloons.clear();
      _endGameMessage = "";
    });
    _ticker.start();
  }

  void _stopGame({required bool won}) {
    _ticker.stop();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _endGameMessage = won
          ? ref.t(LocalizationKeys.youWin)
          : ref.t(LocalizationKeys.gameOver);
    });

    // Show interstitial ad after game ends (win or lose)
    AdHelper.showInterstitialAd(probability: 1.0);

    if (won) {
      _checkReward();
    }
  }

  bool _rewardClaimed = false;

  Future<void> _checkReward() async {
    if (!_rewardClaimed &&
        widget.rewardTask != null &&
        widget.dataRepository != null) {
      _rewardClaimed = true;
      try {
        await widget.dataRepository!.completeTask(widget.rewardTask!.taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Task Completed! +${widget.rewardTask!.reward} HC"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint("Reward claim failed: $e");
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (_screenSize == Size.zero) return;

    // Spawn new balloons
    if (Random().nextDouble() < spawnRate) {
      _spawnBalloon();
    }

    setState(() {
      // Update balloons
      for (var i = _balloons.length - 1; i >= 0; i--) {
        final balloon = _balloons[i];
        balloon.y -= balloon.speed;

        // Check if balloon missed (flew off top)
        if (balloon.y + balloon.radius * 2 < 0) {
          _balloons.removeAt(i);
          _lives--;
          if (_lives <= 0) {
            _stopGame(won: false);
          }
        }
      }
    });
  }

  void _spawnBalloon() {
    final double radius = Random().nextDouble() * 20 + 20; // 20-40 size
    final double x =
        Random().nextDouble() * (_screenSize.width - radius * 2) + radius;
    final double speed = Random().nextDouble() * 2 + 1.5; // 1.5 - 3.5 speed
    final Color color =
        Colors.primaries[Random().nextInt(Colors.primaries.length)];

    _balloons.add(
      Balloon(
        x: x,
        y: _screenSize.height + radius,
        radius: radius,
        speed: speed,
        color: color,
      ),
    );
  }

  void _onTapBalloon(Balloon balloon) {
    if (!_isPlaying) return;

    setState(() {
      _balloons.remove(balloon);
      _score++;
      if (_score >= targetScore) {
        _stopGame(won: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent, // Sky blue
      body: Stack(
        children: [
          // Background Elements (Clouds etc could go here)

          // Game Area with LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              // Update screen size one time or on resize
              if (_screenSize != constraints.biggest) {
                _screenSize = constraints.biggest;
              }
              return Stack(
                children: [
                  // Balloons
                  for (final balloon in _balloons)
                    Positioned(
                      left: balloon.x - balloon.radius,
                      top: balloon.y - balloon.radius,
                      child: GestureDetector(
                        onTap: () => _onTapBalloon(balloon),
                        child: Container(
                          width: balloon.radius * 2,
                          height: balloon.radius * 2 * 1.2, // Slightly oval
                          decoration: BoxDecoration(
                            color: balloon.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.3),
                              radius: 0.8,
                              colors: [
                                Colors.white.withOpacity(0.4),
                                balloon.color,
                              ],
                            ),
                          ),
                          // String detail
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 2,
                              height: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // HUD (Heads Up Display)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  // Banner Ad at Top
                  const BannerAdWidget(backgroundColor: Colors.transparent),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Score
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${ref.t(LocalizationKeys.score)}: $_score / $targetScore",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.f,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Lives
                      Row(
                        children: List.generate(
                          initialLives,
                          (index) => Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.favorite,
                              color: index < _lives ? Colors.red : Colors.grey,
                              size: 28.s,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Start / Game Over Overlay
          if (!_isPlaying)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  padding: ResponsiveUtils.p(30),
                  margin: ResponsiveUtils.p(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isGameOver
                            ? _endGameMessage
                            : ref.t(LocalizationKeys.gameBalloonPopTitle),
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 28.f,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.s),
                      Text(
                        _isGameOver
                            ? "${ref.t(LocalizationKeys.score)}: $_score"
                            : ref.t(LocalizationKeys.balloonPopInstruction),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16.f,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.s),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.angolaYellow,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 15.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _isGameOver
                              ? ref.t(LocalizationKeys.playAgain)
                              : ref.t(LocalizationKeys.play),
                          style: TextStyle(
                            fontSize: 18.f,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.s),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          ref.t(LocalizationKeys.exit),
                          style: TextStyle(color: Colors.grey, fontSize: 16.f),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Back Button
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Balloon {
  double x;
  double y;
  double radius;
  double speed;
  Color color;

  Balloon({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}
