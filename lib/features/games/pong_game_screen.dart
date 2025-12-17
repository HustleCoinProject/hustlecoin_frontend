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

class PongGameScreen extends ConsumerStatefulWidget {
  final Task? rewardTask;
  final DataRepository? dataRepository;

  const PongGameScreen({super.key, this.rewardTask, this.dataRepository});

  @override
  ConsumerState<PongGameScreen> createState() => _PongGameScreenState();
}

class _PongGameScreenState extends ConsumerState<PongGameScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Game Constants
  static const double paddleWidth = 70.0;
  static const double paddleHeight = 15.0;
  static const double ballSize = 15.0;
  static const double gameSpeedBase = 5.0;
  static const double moveSpeed = 6.0;

  // Game State
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _playerScore = 0;
  int _aiScore = 0;
  String _winnerMessage = "";

  // Physics State
  Size _fieldSize = Size.zero;
  Offset _ballPos = Offset.zero;
  Offset _ballVel = Offset.zero;
  double _playerX = 0;
  double _aiX = 0;
  double _currentSpeed = gameSpeedBase;
  double _aiTargetBias = 0; // Error offset for AI

  // Inputs
  bool _movingLeft = false;
  bool _movingRight = false;

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
      _resetBall();
    });
    _ticker.start();
  }

  void _resetBall() {
    // Center ball
    _ballPos = Offset(
      (_fieldSize.width - ballSize) / 2,
      (_fieldSize.height - ballSize) / 2,
    );
    _currentSpeed = gameSpeedBase;
    _aiTargetBias = 0;

    // Random direction (mostly vertical)
    double angle = (Random().nextDouble() * 0.4 + 0.3) * pi; // 0.3pi to 0.7pi
    if (Random().nextBool()) angle += pi; // Flip to up/down

    _ballVel = Offset(cos(angle), sin(angle)) * _currentSpeed;

    // Center paddles
    _playerX = (_fieldSize.width - paddleWidth) / 2;
    _aiX = (_fieldSize.width - paddleWidth) / 2;
  }

  void _stopGame({required bool playerWon}) {
    _ticker.stop();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
      _winnerMessage = playerWon
          ? ref.t(LocalizationKeys.youWin)
          : ref.t(LocalizationKeys.aiWins);
    });

    if (playerWon) {
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
    if (_fieldSize == Size.zero) return;

    setState(() {
      // 1. Player Input Movement
      if (_movingLeft) {
        _playerX -= moveSpeed;
      }
      if (_movingRight) {
        _playerX += moveSpeed;
      }
      _playerX = _playerX.clamp(0.0, _fieldSize.width - paddleWidth);

      // 2. Move Ball
      _ballPos += _ballVel;

      // 3. Wall Collisions (Left/Right)
      if (_ballPos.dx <= 0 || _ballPos.dx >= _fieldSize.width - ballSize) {
        _ballVel = Offset(-_ballVel.dx, _ballVel.dy);
        if (_ballPos.dx <= 0) _ballPos = Offset(0, _ballPos.dy);
        if (_ballPos.dx >= _fieldSize.width - ballSize) {
          _ballPos = Offset(_fieldSize.width - ballSize, _ballPos.dy);
        }
      }

      // 4. Paddle Collisions
      // Player Paddle (Bottom)
      Rect playerRect = Rect.fromLTWH(
        _playerX,
        _fieldSize.height - 20 - paddleHeight,
        paddleWidth,
        paddleHeight,
      );
      Rect ballRect = Rect.fromLTWH(
        _ballPos.dx,
        _ballPos.dy,
        ballSize,
        ballSize,
      );

      if (ballRect.overlaps(playerRect)) {
        // Reverse Y
        _ballVel = Offset(_ballVel.dx, -_ballVel.dy.abs()); // Ensure goes up
        _increaseSpeed();

        // Calculate new AI bias (make mistakes as speed increases)
        // Base error range +/- 10. Adds up to +/- paddleWidth at high speeds
        double errorMagnitude = 10.0 + (_currentSpeed - gameSpeedBase) * 8.0;
        _aiTargetBias = (Random().nextDouble() - 0.5) * 2 * errorMagnitude;
      }

      // AI Paddle (Top)
      Rect aiRect = Rect.fromLTWH(
        _aiX,
        20, // Top padding
        paddleWidth,
        paddleHeight,
      );

      if (ballRect.overlaps(aiRect)) {
        _ballVel = Offset(_ballVel.dx, _ballVel.dy.abs()); // Ensure goes down
        _increaseSpeed();
        _aiTargetBias = 0; // Reset bias on hit
      }

      // 5. Scoring
      if (_ballPos.dy < 0) {
        _playerScore++;
        if (_playerScore >= 5) {
          _stopGame(playerWon: true);
        } else {
          _resetBall();
        }
      } else if (_ballPos.dy > _fieldSize.height) {
        _aiScore++;
        if (_aiScore >= 5) {
          _stopGame(playerWon: false);
        } else {
          _resetBall();
        }
      }

      // 6. AI Movement
      double aiCenter = _aiX + paddleWidth / 2;
      double ballCenter = _ballPos.dx + ballSize / 2;

      // Target combines true position + error bias
      double targetX = ballCenter + _aiTargetBias;
      double diff = targetX - aiCenter;

      // AI speed scales with game speed but stays slightly slower to allow "barely missing"
      double aiMaxSpeed = _currentSpeed * 0.85;

      if (diff.abs() > aiMaxSpeed) {
        _aiX += diff > 0 ? aiMaxSpeed : -aiMaxSpeed;
      } else {
        _aiX += diff;
      }
      _aiX = _aiX.clamp(0.0, _fieldSize.width - paddleWidth);
    });
  }

  void _increaseSpeed() {
    if (_currentSpeed < 14.0) {
      // Slight increase in max speed
      _currentSpeed += 0.5;
      _ballVel = _ballVel / _ballVel.distance * _currentSpeed;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Aesthetic Config
    final bgColor = const Color(0xFF202028);
    final ballColor = Colors.yellowAccent;
    final playerColor = Colors.white;
    final aiColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: BannerAdWidget(backgroundColor: Colors.transparent),
          ),
          Expanded(
            child: Stack(
              children: [
                // Game & Controls (Shifted down)
                Positioned.fill(
                  child: Column(
                    children: [
                      // Game Area
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _fieldSize = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            if (!_isPlaying &&
                                !_isGameOver &&
                                _ballPos == Offset.zero) {
                              _resetBall();
                              _ballVel = Offset.zero;
                            }

                            return Stack(
                              children: [
                                // Midfield Line
                                Center(
                                  child: Container(
                                    width: double.infinity,
                                    height: 2,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),

                                // AI Paddle (Top)
                                Positioned(
                                  left: _aiX,
                                  top: 20,
                                  child: CustomPaint(
                                    size: Size(paddleWidth, paddleHeight),
                                    painter: PixelPaddlePainter(color: aiColor),
                                  ),
                                ),

                                // Player Paddle (Bottom)
                                Positioned(
                                  left: _playerX,
                                  bottom: 20,
                                  child: CustomPaint(
                                    size: Size(paddleWidth, paddleHeight),
                                    painter: PixelPaddlePainter(
                                      color: playerColor,
                                    ),
                                  ),
                                ),

                                // Ball
                                Positioned(
                                  left: _ballPos.dx,
                                  top: _ballPos.dy,
                                  child: CustomPaint(
                                    size: Size(ballSize, ballSize),
                                    painter: PixelBallPainter(color: ballColor),
                                  ),
                                ),

                                // Score Overlay
                                Positioned(
                                  right: 20,
                                  top: _fieldSize.height / 2 - 50,
                                  child: Column(
                                    children: [
                                      RotatedBox(
                                        quarterTurns: 0,
                                        child: Text(
                                          '$_aiScore',
                                          style: TextStyle(
                                            color: aiColor.withOpacity(0.5),
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Courier',
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        '$_playerScore',
                                        style: TextStyle(
                                          color: playerColor.withOpacity(0.5),
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Courier',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Start / Game Over Overlay
                                if (!_isPlaying)
                                  Container(
                                    color: Colors.black.withOpacity(0.6),
                                    child: Center(
                                      child: Container(
                                        padding: EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 4,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(8, 8),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _isGameOver
                                                  ? _winnerMessage
                                                  : ref.t(
                                                      LocalizationKeys
                                                          .gamePongTitle,
                                                    ),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 40.f,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Courier',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20.s),
                                            Text(
                                              ref
                                                  .t(LocalizationKeys.firstTo5)
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16.f,
                                                fontFamily: 'Courier',
                                              ),
                                            ),
                                            SizedBox(height: 40.s),
                                            ElevatedButton(
                                              onPressed: _startGame,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.angolaYellow,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 30.w,
                                                  vertical: 15.h,
                                                ),
                                              ),
                                              child: Text(
                                                _isGameOver
                                                    ? ref.t(
                                                        LocalizationKeys
                                                            .rematch,
                                                      )
                                                    : ref.t(
                                                        LocalizationKeys.serve,
                                                      ),
                                                style: TextStyle(
                                                  fontSize: 20.f,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20.s),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                ref.t(LocalizationKeys.exit),
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 16.f,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Controls Area
                      SafeArea(
                        top: false,
                        child: Container(
                          height: 120,
                          color: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildControlButton(Icons.arrow_back, (
                                  pressed,
                                ) {
                                  setState(() => _movingLeft = pressed);
                                }),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: _buildControlButton(
                                  Icons.arrow_forward,
                                  (pressed) {
                                    setState(() => _movingRight = pressed);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Back Button (Top Left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Function(bool) onStateChange) {
    return GestureDetector(
      onTapDown: (_) => onStateChange(true),
      onTapUp: (_) => onStateChange(false),
      onTapCancel: () => onStateChange(false),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(child: Icon(icon, color: Colors.white, size: 40)),
      ),
    );
  }
}

// --- Painters ---

class PixelPaddlePainter extends CustomPainter {
  final Color color;
  PixelPaddlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Draw a "pixelated" paddle (just a rect for now, but sharp edges)
    canvas.drawRect(Offset.zero & size, paint);

    // Add a highlight pixel line
    // paint.color = Colors.white.withOpacity(0.3);
    // canvas.drawRect(Rect.fromLTWH(0, 0, 4, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelBallPainter extends CustomPainter {
  final Color color;
  PixelBallPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Square ball for pong feel
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
