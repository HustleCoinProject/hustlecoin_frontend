import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/task.dart';
import 'package:hustlecoin/data/repositories/data_repository.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

class RunnerGameScreen extends ConsumerStatefulWidget {
  final Task? rewardTask;
  final int targetScore;
  final DataRepository? dataRepository;

  const RunnerGameScreen({
    super.key,
    this.rewardTask,
    this.targetScore = 600,
    this.dataRepository,
  });

  @override
  ConsumerState<RunnerGameScreen> createState() => _RunnerGameScreenState();
}

class _RunnerGameScreenState extends ConsumerState<RunnerGameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Game State
  bool _isPlaying = false;
  bool _isGameOver = false;
  double _score = 0;
  double _speed = 5.0;

  // Reward State
  bool _rewardClaimed = false;

  // Player State
  double _playerY = 0;
  double _playerVelocity = 0;
  final double _gravity = 0.8;
  final double _jumpForce = -15.0;
  final double _groundY = 0;
  bool _isJumping = false;

  // Obstacles
  List<Obstacle> _obstacles = [];
  double _spawnTimer = 0;

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
      _speed = 5.0;
      _playerY = _groundY;
      _playerVelocity = 0;
      _obstacles.clear();
      _spawnTimer = 0;
      _rewardClaimed =
          false; // Reset reward for new run (optional, user req implies one time but typical games allow repetitive, though backend might limit)
      // Actually backend limits often apply. But let's allow trying to claim again if failed.
      // But let's assume one claim per session.
    });
    _ticker.start();
  }

  void _stopGame() {
    _ticker.stop();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
  }

  void _jump() {
    if (!_isPlaying || _isGameOver) return;

    if (!_isJumping) {
      setState(() {
        _playerVelocity = _jumpForce;
        _isJumping = true;
      });
    }
  }

  Future<void> _checkReward() async {
    if (!_rewardClaimed &&
        widget.rewardTask != null &&
        widget.dataRepository != null &&
        _score >= widget.targetScore) {
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
        // Ignore error (maybe already claimed today)
        debugPrint("Reward claim failed: $e");
      }
    }
  }

  void _onTick(Duration elapsed) {
    setState(() {
      // Update Physics
      _playerVelocity += _gravity;
      _playerY += _playerVelocity;

      // Ground Collision
      if (_playerY >= _groundY) {
        _playerY = _groundY;
        _playerVelocity = 0;
        _isJumping = false;
      }

      // Update Obstacles
      _spawnTimer += 1;
      if (_spawnTimer > (100 - _speed * 2).clamp(40, 100)) {
        if (Random().nextBool()) {
          _obstacles.add(Obstacle(x: MediaQuery.of(context).size.width));
          _spawnTimer = 0;
        }
      }

      for (var obstacle in _obstacles) {
        obstacle.x -= _speed;
      }

      _obstacles.removeWhere((o) => o.x < -50);

      // Collision Detection
      final playerRect = Rect.fromLTWH(
        50,
        MediaQuery.of(context).size.height * 0.6 + _playerY - 40,
        40, // Slightly smaller hitbox for pixel feel
        40,
      );

      for (var obstacle in _obstacles) {
        final obstacleRect = Rect.fromLTWH(
          obstacle.x,
          MediaQuery.of(context).size.height * 0.6 - 40,
          40,
          40,
        );

        if (playerRect.overlaps(obstacleRect)) {
          final intersection = playerRect.intersect(obstacleRect);
          if (intersection.width > 10 && intersection.height > 10) {
            _stopGame();
          }
        }
      }

      // Score
      _score += 0.1;
      _checkReward(); // Check if threshold met

      // Progressive Speed Increase
      // Base speed 5.0, adds +1 speed for every 300 points
      _speed = 5.0 + (_score / 300.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Indie Palette
    final bgColor = const Color(0xFF202028); // Dark grey/purple
    final groundColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: BannerAdWidget(backgroundColor: Colors.transparent),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _isPlaying ? _jump : null,
              child: Stack(
                children: [
                  // Background - Static noise or just plain flat
                  Positioned.fill(child: Container(color: bgColor)),

                  // Ground Line - Single pixel hard line
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.4,
                    left: 0,
                    right: 0,
                    height: 4, // Thick line
                    child: Container(color: groundColor),
                  ),

                  // Player - Pixel Art
                  Positioned(
                    left: 50,
                    bottom: MediaQuery.of(context).size.height * 0.4 - _playerY,
                    child: CustomPaint(
                      size: const Size(40, 40),
                      painter: PixelRunnerPainter(
                        color: Colors.white,
                        isJumping: _isJumping,
                      ),
                    ),
                  ),

                  // Obstacles - Pixel Art
                  ..._obstacles.map(
                    (obstacle) => Positioned(
                      left: obstacle.x,
                      bottom: MediaQuery.of(context).size.height * 0.4,
                      child: CustomPaint(
                        size: const Size(40, 40),
                        painter: PixelObstaclePainter(),
                      ),
                    ),
                  ),

                  // UI Layer
                  SafeArea(
                    top: false, // Already handled by top banner area
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Text(
                                '${ref.t(LocalizationKeys.score).toUpperCase()}: ${_score.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Start / Game Over Screen
                  if (!_isPlaying)
                    Container(
                      color: Colors.black.withOpacity(0.4), // Dithered feel
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isGameOver
                                    ? ref.t(LocalizationKeys.gameOver)
                                    : ref
                                          .t(LocalizationKeys.gameRunnerTitle)
                                          .toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 32.f,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier',
                                  letterSpacing: -2,
                                ),
                              ),
                              SizedBox(height: 20.s),
                              if (_isGameOver) ...[
                                Text(
                                  '${ref.t(LocalizationKeys.score).toUpperCase()}: ${_score.toInt()}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24.f,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.s),
                                Text(
                                  '+ HC ${ref.t(LocalizationKeys.reward).replaceAll(':', '').toUpperCase()}',
                                  style: TextStyle(
                                    color: AppColors.angolaYellow,
                                    fontSize: 16.f,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold,
                                    backgroundColor: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 30.s),
                              ],
                              PressableScaleWidget(
                                onTap: _startGame,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30.w,
                                    vertical: 10.h,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Text(
                                    _isGameOver
                                        ? ref.t(LocalizationKeys.playAgain)
                                        : ref.t(LocalizationKeys.play),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.f,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
}

class Obstacle {
  double x;
  Obstacle({required this.x});
}

// --- Painters ---

class PixelRunnerPainter extends CustomPainter {
  final Color color;
  final bool isJumping;

  PixelRunnerPainter({required this.color, required this.isJumping});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final p = w / 8; // Pixel unit

    // Run animation frame (simulated by isJumping for now)
    // If jumping, legs up. If not, standing/running.

    // Head
    canvas.drawRect(Rect.fromLTWH(2 * p, 1 * p, 4 * p, 3 * p), paint);

    // Body
    canvas.drawRect(Rect.fromLTWH(3 * p, 4 * p, 2 * p, 2 * p), paint);

    // Arms
    canvas.drawRect(Rect.fromLTWH(2 * p, 4 * p, 1 * p, 2 * p), paint);

    // Legs
    if (isJumping) {
      // Jump pose
      canvas.drawRect(Rect.fromLTWH(2 * p, 6 * p, 1 * p, 1 * p), paint); // L
      canvas.drawRect(Rect.fromLTWH(5 * p, 6 * p, 1 * p, 1 * p), paint); // R
    } else {
      // Stand/Run pose
      canvas.drawRect(Rect.fromLTWH(3 * p, 6 * p, 1 * p, 2 * p), paint); // L
      canvas.drawRect(Rect.fromLTWH(4 * p, 6 * p, 1 * p, 2 * p), paint); // R
    }

    // Eye (void)
    final eyePaint = Paint()..color = const Color(0xFF202028); // Bg color
    canvas.drawRect(Rect.fromLTWH(4.5 * p, 1.5 * p, 1 * p, 1 * p), eyePaint);
  }

  @override
  bool shouldRepaint(covariant PixelRunnerPainter oldDelegate) {
    return oldDelegate.isJumping != isJumping;
  }
}

class PixelObstaclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.redAccent;
    final w = size.width;
    final p = w / 8;

    // A glitchy block or spike
    // Base
    canvas.drawRect(Rect.fromLTWH(1 * p, 6 * p, 6 * p, 2 * p), paint);
    // Spikes
    canvas.drawRect(Rect.fromLTWH(2 * p, 4 * p, 1 * p, 2 * p), paint);
    canvas.drawRect(Rect.fromLTWH(5 * p, 3 * p, 1 * p, 3 * p), paint);
    canvas.drawRect(Rect.fromLTWH(3.5 * p, 5 * p, 1 * p, 1 * p), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
