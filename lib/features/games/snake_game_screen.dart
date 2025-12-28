import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/task.dart';
import 'package:hustlecoin/data/repositories/data_repository.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/pressable_scale_widget.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

import 'package:hustlecoin/utils/ad_helper.dart';

class SnakeGameScreen extends ConsumerStatefulWidget {
  final Task? rewardTask;
  final int targetScore;
  final DataRepository? dataRepository;

  const SnakeGameScreen({
    super.key,
    this.rewardTask,
    this.targetScore = 50,
    this.dataRepository,
  });

  @override
  ConsumerState<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class _SnakeGameScreenState extends ConsumerState<SnakeGameScreen> {
  // Game Configuration
  static const int rows = 20;
  static const int columns = 20;

  // Game State
  List<Point<int>> _snake = [const Point(10, 10)];
  Point<int> _food = const Point(5, 5);
  Direction _direction = Direction.up;
  Direction _nextDirection = Direction.up;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isGameOver = false;
  int _score = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _score = 0;
      _snake = [const Point(10, 10), const Point(10, 11), const Point(10, 12)];
      _direction = Direction.up;
      _nextDirection = Direction.up;
      _generateFood();
    });
    _timer?.cancel();
    _score = 0;
    _scheduleTick();
  }

  void _scheduleTick() {
    if (!_isPlaying) return;

    // Calculate speed: Start at 200ms, decrease by 5ms for every 10 points (1 food)
    // Cap at 50ms (fastest)
    int currentSpeed = max(
      50,
      200 - (_score ~/ 2),
    ); // e.g. score 150 -> 200 - 75 = 125ms. score 300 -> 50ms.

    _timer = Timer(Duration(milliseconds: currentSpeed), _onTick);
  }

  void _stopGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });
    AdHelper.showInterstitialAd(probability: 1.0);
  }

  void _generateFood() {
    final random = Random();
    Point<int> newFood;
    while (true) {
      newFood = Point(random.nextInt(columns), random.nextInt(rows));
      if (!_snake.contains(newFood)) {
        _food = newFood;
        break;
      }
    }
  }

  void _onTick() {
    setState(() {
      _direction = _nextDirection;
      Point<int> newHead;

      switch (_direction) {
        case Direction.up:
          newHead = Point(_snake.first.x, _snake.first.y - 1);
          break;
        case Direction.down:
          newHead = Point(_snake.first.x, _snake.first.y + 1);
          break;
        case Direction.left:
          newHead = Point(_snake.first.x - 1, _snake.first.y);
          break;
        case Direction.right:
          newHead = Point(_snake.first.x + 1, _snake.first.y);
          break;
      }

      // WRAP AROUND LOGIC
      int wrappedX = newHead.x;
      int wrappedY = newHead.y;

      if (newHead.x < 0) wrappedX = columns - 1;
      if (newHead.x >= columns) wrappedX = 0;
      if (newHead.y < 0) wrappedY = rows - 1;
      if (newHead.y >= rows) wrappedY = 0;

      newHead = Point(wrappedX, wrappedY);

      // Check Collision with Self
      if (_snake.contains(newHead)) {
        _stopGame();
        return;
      }

      _snake.insert(0, newHead);

      // Check Food
      if (newHead == _food) {
        _score += 10;
        _generateFood();
        _checkReward(); // Check if threshold met
        // Just grow (don't remove tail)
      } else {
        _snake.removeLast();
      }
    });

    _scheduleTick();
  }

  bool _rewardClaimed = false;

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
        debugPrint("Reward claim failed: $e");
      }
    }
  }

  void _changeDirection(Direction newDir) {
    if (!_isPlaying || _isGameOver) return;

    // Prevent reversing direction
    if ((_direction == Direction.up && newDir == Direction.down) ||
        (_direction == Direction.down && newDir == Direction.up) ||
        (_direction == Direction.left && newDir == Direction.right) ||
        (_direction == Direction.right && newDir == Direction.left)) {
      return;
    }

    _nextDirection = newDir;
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (details.delta.dx.abs() > details.delta.dy.abs()) {
      // Horizontal Swap
      if (details.delta.dx > 0) {
        _changeDirection(Direction.right);
      } else {
        _changeDirection(Direction.left);
      }
    } else {
      // Vertical Swap
      if (details.delta.dy > 0) {
        _changeDirection(Direction.down);
      } else {
        _changeDirection(Direction.up);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nokia 3310-ish Colors
    final Color backgroundColor = const Color(0xFF43523d); // Deep greenish
    final Color snakeColor = Colors.red; // Red as requested
    final Color foodColor = Colors.redAccent;
    final Color gridColor = const Color(0xFF3b4936);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onPanUpdate: _handleSwipe,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              // Banner Ad
              const BannerAdWidget(backgroundColor: Colors.transparent),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      '${ref.t(LocalizationKeys.score).toUpperCase()}: $_score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.f,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              // Game Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: columns / rows,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                        color: backgroundColor.withOpacity(0.8),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellSize = constraints.maxWidth / columns;
                          return Stack(
                            children: [
                              // Optional: faint grid
                              ...List.generate(
                                rows,
                                (y) => List.generate(
                                  columns,
                                  (x) => Positioned(
                                    left: x * cellSize,
                                    top: y * cellSize,
                                    width: cellSize,
                                    height: cellSize,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: gridColor,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).expand((e) => e),

                              // Food
                              Positioned(
                                left: _food.x * cellSize,
                                top: _food.y * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: Center(
                                  child: Container(
                                    width: cellSize * 0.8,
                                    height: cellSize * 0.8,
                                    decoration: BoxDecoration(
                                      color: foodColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),

                              // Snake
                              ..._snake.map((point) {
                                return Positioned(
                                  left: point.x * cellSize,
                                  top: point.y * cellSize,
                                  width: cellSize,
                                  height: cellSize,
                                  child: Container(
                                    margin: const EdgeInsets.all(1),
                                    color: snakeColor,
                                  ),
                                );
                              }),

                              // Game Over Overlay
                              if (_isGameOver || !_isPlaying && _score == 0)
                                Center(
                                  child: GlassContainer(
                                    borderRadius: 20,
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isGameOver
                                              ? ref.t(LocalizationKeys.gameOver)
                                              : ref
                                                    .t(
                                                      LocalizationKeys
                                                          .gameSnakeTitle,
                                                    )
                                                    .toUpperCase(),
                                          style: TextStyle(
                                            color: _isGameOver
                                                ? Colors.red
                                                : Colors.white,
                                            fontSize: 32.f,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Courier',
                                          ),
                                        ),
                                        SizedBox(height: 16.s),
                                        if (_isGameOver)
                                          Text(
                                            '${ref.t(LocalizationKeys.score).toUpperCase()}: ${_score.toInt()}',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 20.f,
                                              fontFamily: 'Courier',
                                            ),
                                          ),
                                        SizedBox(height: 24.s),
                                        PressableScaleWidget(
                                          onTap: _startGame,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 32.w,
                                              vertical: 12.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.angolaYellow,
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                            child: Text(
                                              _isGameOver
                                                  ? ref.t(
                                                      LocalizationKeys
                                                          .playAgain,
                                                    )
                                                  : ref.t(
                                                      LocalizationKeys.play,
                                                    ),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.f,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16.s),
                                        if (!_isGameOver)
                                          Text(
                                            ref.t(LocalizationKeys.swipeToMove),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontSize: 12.f,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
