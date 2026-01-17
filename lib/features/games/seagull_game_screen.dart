import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hustlecoin/data/models/task.dart';
import 'package:hustlecoin/data/repositories/data_repository.dart';
import 'package:hustlecoin/theme/app_colors.dart';
import 'package:hustlecoin/utils/localization.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';
import 'package:hustlecoin/widgets/glass_container.dart';
import 'package:hustlecoin/widgets/banner_ad_widget.dart';
import 'package:hustlecoin/utils/ad_helper.dart';

// --- Models ---

enum FoodState { shadow, falling, landed, eaten }

class GameEntity {
  Offset position;
  final bool isPlayer;
  Color color;
  // For AI smoothing
  Offset? target;

  GameEntity({
    required this.position,
    this.isPlayer = false,
    this.color = Colors.white,
  });
}

class FoodItem {
  final String id;
  Offset position;
  Offset dropStartPosition;
  FoodState state;
  double dropProgress; // 0.0 to 1.0
  DateTime createdAt;

  FoodItem({required this.id, required this.position})
    : dropStartPosition = Offset(
        position.dx,
        position.dy - 300,
      ), // Start from above
      state = FoodState.shadow,
      dropProgress = 0.0,
      createdAt = DateTime.now();
}

// --- Screen ---

class SeagullGameScreen extends ConsumerStatefulWidget {
  final Task? rewardTask;
  final int targetScore;
  final DataRepository? dataRepository;
  final bool isMissionMode;
  final VoidCallback? onMissionCompleted;

  const SeagullGameScreen({
    super.key,
    this.rewardTask,
    this.targetScore = 50,
    this.dataRepository,
    this.isMissionMode = false,
    this.onMissionCompleted,
  });

  @override
  ConsumerState<SeagullGameScreen> createState() => _SeagullGameScreenState();
}

class _SeagullGameScreenState extends ConsumerState<SeagullGameScreen>
    with SingleTickerProviderStateMixin {
  // Game Config
  static const double moveSpeed = 4.0;
  static const double npcSpeed = 2.5; // Slightly slower than player
  static const double shadowDurationMs = 2000;
  static const double fallDurationMs = 500;
  static const double spawnIntervalMs = 2500;

  // State
  late Ticker _ticker;
  final Random _random = Random();
  late Size _worldSize;

  // Entities
  late GameEntity _player;
  late List<GameEntity> _npcs;
  List<FoodItem> _foodItems = [];

  // Logic
  bool _isPlaying = false;
  int _score = 0;
  DateTime _lastSpawnTime = DateTime.now();
  DateTime _lastNpcSpawnTime = DateTime.now(); // For progressive difficulty
  Offset _joystickDelta = Offset.zero; // -1 to 1

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _worldSize = const Size(400, 600);
    _player = GameEntity(
      position: const Offset(200, 300),
      isPlayer: true,
      color: Colors.white,
    );
    _npcs = [];
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _foodItems.clear();
      _player.position = Offset(_worldSize.width / 2, _worldSize.height / 2);

      // Spawn 3 NPCs at random locations
      _npcs = List.generate(3, (index) {
        return GameEntity(
          position: Offset(
            _random.nextDouble() * _worldSize.width,
            _random.nextDouble() * _worldSize.height,
          ),
          color: Colors.grey.shade300,
        );
      });

      final now = DateTime.now();
      _lastSpawnTime = now;
      _lastNpcSpawnTime = now;
    });
    _ticker.start();
  }

  void _stopGame() {
    _ticker.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _onTick(Duration elapsed) {
    if (!_isPlaying) return;

    final now = DateTime.now();

    setState(() {
      // 1. Spawning Logic
      // Food Spawning
      if (now.difference(_lastSpawnTime).inMilliseconds > spawnIntervalMs) {
        _spawnFood();
        _lastSpawnTime = now;
      }

      // NPC Spawning (Progressive Difficulty)
      // Every 15 seconds, add a new seagull
      if (now.difference(_lastNpcSpawnTime).inSeconds > 15) {
        _npcs.add(
          GameEntity(
            position: Offset(
              _random.nextDouble() * _worldSize.width,
              _random.nextDouble() * _worldSize.height,
            ),
            color: Colors.grey.shade300,
          ),
        );
        _lastNpcSpawnTime = now;
      }

      // 2. Update Food States
      for (var food in _foodItems) {
        final age = now.difference(food.createdAt).inMilliseconds;

        if (food.state == FoodState.shadow) {
          if (age > shadowDurationMs) {
            food.state = FoodState.falling;
            // Reset "drop start" time reference effectively by managing progress
          }
        } else if (food.state == FoodState.falling) {
          double progress = (age - shadowDurationMs) / fallDurationMs;
          if (progress >= 1.0) {
            food.dropProgress = 1.0;
            food.state = FoodState.landed;
          } else {
            food.dropProgress = progress;
          }
        }
      }

      // 3. Player Movement
      if (_joystickDelta != Offset.zero) {
        _player.position += _joystickDelta * moveSpeed;
        _clampEntity(_player);
      }

      // 4. NPC AI
      for (var npc in _npcs) {
        FoodItem? targetFood;
        double minDist = double.infinity;

        // Find nearest landed food
        for (var food in _foodItems) {
          if (food.state == FoodState.landed) {
            double dist = (food.position - npc.position).distance;
            if (dist < minDist) {
              minDist = dist;
              targetFood = food;
            }
          }
        }

        Offset moveDir = Offset.zero;

        if (targetFood != null) {
          // CHASE MODE
          npc.target = null; // Clear wander target
          Offset dir = targetFood.position - npc.position;
          if (dir.distance > 0) {
            moveDir = dir / dir.distance; // Normalize
          }
        } else {
          // WANDER MODE
          // Pick a target if none or reached
          if (npc.target == null ||
              (npc.target! - npc.position).distance < 10) {
            npc.target = Offset(
              50 + _random.nextDouble() * (_worldSize.width - 100),
              50 + _random.nextDouble() * (_worldSize.height - 100),
            );
          }

          Offset dir = npc.target! - npc.position;
          if (dir.distance > 0) {
            moveDir = dir / dir.distance;
          }
        }

        // SEPARATION (Prevent stacking)
        Offset separation = Offset.zero;
        int separationCount = 0;
        for (var other in _npcs) {
          if (other == npc) continue;
          double d = (npc.position - other.position).distance;
          if (d < 40 && d > 0) {
            // Keep them 40 pixels apart
            Offset push = (npc.position - other.position) / d; // Normalize push
            separation += push;
            separationCount++;
          }
        }

        // Also separate from player
        double dPlayer = (npc.position - _player.position).distance;
        if (dPlayer < 40 && dPlayer > 0) {
          Offset push = (npc.position - _player.position) / dPlayer;
          separation += push;
          separationCount++;
        }

        if (separationCount > 0) {
          separation = separation / separationCount.toDouble();
          // Blend movement: 70% Goal, 30% Separation
          moveDir = (moveDir * 0.7) + (separation * 1.5);
          // Re-normalize if needed, or just let them speed up slightly to escape
          if (moveDir.distance > 0) {
            moveDir = moveDir / moveDir.distance;
          }
        }

        // Apply Movement
        npc.position += moveDir * npcSpeed;
        _clampEntity(npc);
      }

      // 5. Collision Detection (Eat Food)
      // Check Player
      _checkEating(_player);
      // Check NPCs
      for (var npc in _npcs) {
        _checkEating(npc);
      }

      // Cleanup
      _foodItems.removeWhere((f) => f.state == FoodState.eaten);
    });
  }

  void _spawnFood() {
    // Spawn margin to avoid edges
    final x = 50 + _random.nextDouble() * (_worldSize.width - 100);
    final y = 100 + _random.nextDouble() * (_worldSize.height - 200);

    _foodItems.add(
      FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        position: Offset(x, y),
      ),
    );
  }

  void _clampEntity(GameEntity entity) {
    double x = entity.position.dx.clamp(0.0, _worldSize.width);
    double y = entity.position.dy.clamp(0.0, _worldSize.height);
    entity.position = Offset(x, y);
  }

  void _checkEating(GameEntity entity) {
    for (var food in _foodItems) {
      if (food.state == FoodState.landed) {
        double dist = (entity.position - food.position).distance;
        if (dist < 30) {
          // Catch radius
          food.state = FoodState.eaten; // Mark for removal
          if (entity.isPlayer) {
            _score += 10;
            if (widget.isMissionMode && _score >= widget.targetScore) {
              _isPlaying = false; // Stop updates
              // Trigger success overlay (Seagull uses overlay logic based on isMissionMode)
              // Wait, Seagull uses _isPlaying to toggle HUD. But it doesn't auto-stop in original logic?
              // Original logic doesn't stop. We should force stop or show overlay.
              // Re-using _stopGame is tricky because it stops ticker.
              // Let's call _stopGame(won: true) but wait... this file doesn't have _stopGame(won) signature like BalloonPop.
              // It has no-arg _stopGame().
              // And overlay logic is "if (!_isPlaying)".
              // So stopping game will show overlay.
              _stopGame();
            } else {
              _checkReward();
            }
          }
        }
      }
    }
  }

  bool _rewardClaimed = false;

  Future<void> _checkReward() async {
    // Only verify reward in normal mode
    if (widget.isMissionMode) return;

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

  @override
  Widget build(BuildContext context) {
    // Background Color - Sand/Beach
    final bgColor = Color(0xFFe3dac9);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SafeArea(
            bottom: false,
            child: BannerAdWidget(backgroundColor: Colors.transparent),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Update world size once
                _worldSize = Size(constraints.maxWidth, constraints.maxHeight);

                return Stack(
                  children: [
                    // 1. World Layer (Shadows, Food, Entities)
                    // We need to sort by Y position for fake isometric depth?
                    // Or just z-ordering: Shadows -> Landed Food -> Birds -> Falling Food

                    // Shadows (Now Blocky)
                    ..._foodItems.where((f) => f.state != FoodState.eaten).map((
                      food,
                    ) {
                      // Shadow opacity grows
                      double opacity = 0.0;
                      double scale = 0.5;
                      if (food.state == FoodState.shadow) {
                        final ageMs = DateTime.now()
                            .difference(food.createdAt)
                            .inMilliseconds;
                        final progress = (ageMs / shadowDurationMs).clamp(
                          0.0,
                          1.0,
                        );
                        opacity = 0.5 * progress;
                        scale = 0.5 + (0.5 * progress);
                      } else {
                        opacity = 0.5; // Full shadow when falling/landed
                        scale = 1.0;
                      }

                      return Positioned(
                        left: food.position.dx - (15 * scale),
                        top: food.position.dy - (5 * scale),
                        child: Container(
                          width: 30 * scale,
                          height: 10 * scale,
                          color: Colors.black.withOpacity(opacity),
                        ),
                      );
                    }),

                    // Landed Food (Pixel Art)
                    ..._foodItems.where((f) => f.state == FoodState.landed).map(
                      (food) {
                        return Positioned(
                          left: food.position.dx - 15,
                          top: food.position.dy - 15,
                          child: CustomPaint(
                            size: const Size(30, 30),
                            painter: PixelFryPainter(),
                          ),
                        );
                      },
                    ),

                    // NPCs (Pixel Art)
                    ..._npcs.map((npc) => _buildPixelBird(npc)),

                    // Player (Pixel Art)
                    _buildPixelBird(_player),

                    // Falling Food (Pixel Art)
                    ..._foodItems
                        .where((f) => f.state == FoodState.falling)
                        .map((food) {
                          final currentY =
                              food.dropStartPosition.dy +
                              (food.position.dy - food.dropStartPosition.dy) *
                                  food.dropProgress;

                          return Positioned(
                            left: food.position.dx - 15,
                            top: currentY - 15, // Sprite offset
                            child: CustomPaint(
                              size: const Size(30, 30),
                              painter: PixelFryPainter(),
                            ),
                          );
                        }),

                    // UI Layer (Score, Joystick, Back Button)
                    SafeArea(
                      top: false, // Handled by banner space
                      child: Column(
                        children: [
                          // Top Bar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () {
                                    AdHelper.showInterstitialAd(
                                      probability: 1.0,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                                GlassContainer(
                                  borderRadius: 20.r,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 10.h,
                                  ),
                                  child: Text(
                                    '${ref.t(LocalizationKeys.score)}: $_score',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.f,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    AdHelper.showInterstitialAd(
                                      probability: 1.0,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Start Screen / Joystick
                          if (!_isPlaying)
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (widget.isMissionMode &&
                                      _score >= widget.targetScore) {
                                    widget.onMissionCompleted?.call();
                                  } else {
                                    _startGame();
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40.w,
                                    vertical: 20.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.angolaYellow,
                                    borderRadius: BorderRadius.circular(30.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _isPlaying
                                        ? ""
                                        : (widget.isMissionMode &&
                                                  _score >= widget.targetScore
                                              ? "NEXT TASK"
                                              : ref
                                                    .t(
                                                      LocalizationKeys
                                                          .startGame,
                                                    )
                                                    .toUpperCase()),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24.f,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          if (_isPlaying)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: _VirtualJoystick(
                                onChange: (delta) {
                                  _joystickDelta = delta;
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelBird(GameEntity bird) {
    return Positioned(
      left: bird.position.dx - 20,
      top: bird.position.dy - 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bird Sprite
          CustomPaint(
            size: const Size(40, 40),
            painter: PixelBirdPainter(
              color: bird.isPlayer ? Colors.white : Colors.grey.shade400,
              isPlayer: bird.isPlayer,
            ),
          ),
          if (bird.isPlayer)
            // Indicator for player
            Positioned(
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.angolaYellow,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Painters ---

class PixelBirdPainter extends CustomPainter {
  final Color color;
  final bool isPlayer;

  PixelBirdPainter({required this.color, required this.isPlayer});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;

    // Pixel scale
    final p = w / 8; // 8x8 grid roughly

    // Body (Center block)
    canvas.drawRect(Rect.fromLTWH(3 * p, 2 * p, 2 * p, 4 * p), paint);

    // Head
    canvas.drawRect(Rect.fromLTWH(3 * p, 1 * p, 2 * p, 1 * p), paint);

    // Wings (Outstretched)
    canvas.drawRect(Rect.fromLTWH(1 * p, 3 * p, 2 * p, 1 * p), paint); // Left
    canvas.drawRect(Rect.fromLTWH(5 * p, 3 * p, 2 * p, 1 * p), paint); // Right

    // Beak (Yellow)
    paint.color = Colors.orange;
    canvas.drawRect(Rect.fromLTWH(4 * p, 1.5 * p, 1 * p, 0.5 * p), paint);

    // Eyes (Black)
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(3.2 * p, 1.2 * p, 0.3 * p, 0.3 * p), paint);

    // Outline (Optional - Black border for everything would change logic,
    // keep simple for now)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelFryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()..color = Colors.red;
    final fryPaint = Paint()..color = Colors.yellow;

    final w = size.width;
    final p = w / 8;

    // Box (Red container)
    canvas.drawRect(Rect.fromLTWH(2 * p, 4 * p, 4 * p, 3 * p), boxPaint);

    // Fries (Sticking out)
    canvas.drawRect(Rect.fromLTWH(2.5 * p, 1 * p, 0.5 * p, 3 * p), fryPaint);
    canvas.drawRect(
      Rect.fromLTWH(3.5 * p, 1.5 * p, 0.5 * p, 2.5 * p),
      fryPaint,
    );
    canvas.drawRect(Rect.fromLTWH(4.5 * p, 1 * p, 0.5 * p, 3 * p), fryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Joystick Widget ---

class _VirtualJoystick extends StatefulWidget {
  final ValueChanged<Offset> onChange;

  const _VirtualJoystick({required this.onChange});

  @override
  State<_VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<_VirtualJoystick> {
  Offset _dragOffset = Offset.zero;

  void _updateDelta(Offset offset) {
    final dist = offset.distance;
    final normalized = dist > 0 ? offset / dist : Offset.zero;
    // Cap at radius
    final clampedDist = min(dist, 50.0); // 50 is joystick radius

    // Feedback value -1 to 1
    widget.onChange(normalized * (clampedDist / 50.0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _dragOffset = Offset.zero;
        });
        widget.onChange(Offset.zero);
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
          // Clamp visual knob
          double dist = _dragOffset.distance;
          if (dist > 50) {
            _dragOffset = (_dragOffset / dist) * 50;
          }
        });
        _updateDelta(_dragOffset);
      },
      onPanEnd: (details) {
        setState(() {
          _dragOffset = Offset.zero;
        });
        widget.onChange(Offset.zero);
      },
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          // No perfect circle, maybe an octagon or square for pixel art joystick?
          // Let's keep circle but add pixel border
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white30, width: 4),
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragOffset,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle, // Square knob
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
