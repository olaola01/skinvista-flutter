import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skinvista/bloc/game_score/save_game_score_event.dart';
import 'package:skinvista/bloc/game_score/save_game_score_state.dart';
import 'package:skinvista/core/res/media.dart';
import 'package:skinvista/repositories/game_score_repository.dart';
import 'package:skinvista/screens/leaderboard.dart';
import '../bloc/game_score/save_game_score_bloc.dart';
import '../bloc/leaderboard/leaderboard_bloc.dart';
import '../core/locator.dart';

class SkincarePop extends StatefulWidget {
  const SkincarePop({super.key});

  @override
  State<SkincarePop> createState() => _SkincarePopState();
}

class _SkincarePopState extends State<SkincarePop> with TickerProviderStateMixin {
  int _score = 0;
  double _timeLeft = 60.0;
  List<Bubble> _bubbles = [];
  String _selectedTool = '';
  late Timer _gameTimer;
  bool _gameOver = false;
  bool _showTooltip = true;
  bool _showGestureDemo = false;
  bool _gameStarted = false;
  int _level = 1;
  int _tutorialStep = 0;
  late AnimationController _fingerController;
  late Animation<Offset> _fingerAnimation;
  late Animation<double> _glowAnimation;
  BuildContext? _blocContext;

  // Animation controllers for tool selection
  final Map<String, AnimationController> _toolAnimationControllers = {};

  final List<Map<String, dynamic>> tools = [
    {'name': 'Anti-Itch Cream', 'cures': 'Eczema', 'icon': Icons.healing, 'color': const Color(0xFF40C4FF), 'image': Media.eczemaIcon},
    {'name': 'Cleanser', 'cures': 'Acne', 'icon': Icons.water_drop, 'color': const Color(0xFFFF6F61), 'image': Media.acneIcon},
    {'name': 'Moisturizer', 'cures': 'Ashy Skin', 'icon': Icons.opacity, 'color': const Color(0xFFCE93D8), 'image': Media.ashySkinIcon},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each tool
    for (var tool in tools) {
      _toolAnimationControllers[tool['name']] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
    }

    _fingerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && _showGestureDemo) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _tutorialStep++;
              if (_tutorialStep < 6) {
                _updateFingerAnimation();
                _fingerController.forward(from: 0);
              } else {
                _showGestureDemo = false;
                _showTooltip = true;
              }
            });
          }
        });
      }
    });

    _fingerAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _fingerController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fingerController, curve: Curves.easeInOut),
    );

    _startGestureDemo();
  }

  void _startGestureDemo() {
    _tutorialStep = 0;
    _showTooltip = false;
    _showGestureDemo = true;
    _updateFingerAnimation();
    _fingerController.forward(from: 0);
  }

  void _updateFingerAnimation() {
    if (_tutorialStep >= 6) return;
    final toolIndex = _tutorialStep ~/ 2;
    final isToolTap = _tutorialStep % 2 == 0;
    final toolX = 70 + toolIndex * 100.0;
    final bubbleX = 150.0;
    final bubbleY = 200.0;

    if (isToolTap) {
      _fingerAnimation = Tween<Offset>(
        begin: Offset(toolX, 450),
        end: Offset(toolX, 420),
      ).animate(CurvedAnimation(parent: _fingerController, curve: Curves.easeInOut));
    } else {
      _fingerAnimation = Tween<Offset>(
        begin: Offset(bubbleX, bubbleY + 50),
        end: Offset(bubbleX, bubbleY),
      ).animate(CurvedAnimation(parent: _fingerController, curve: Curves.easeInOut));
    }
  }

  void _startGame() {
    if (_gameStarted) return;
    _score = 0;
    _timeLeft = 60.0;
    _bubbles.clear();
    _gameOver = false;
    _gameStarted = true;

    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timeLeft -= 0.1;
        if (_timeLeft <= 0) {
          _endGame();
          timer.cancel();
        } else {
          _spawnBubble();
          _updateBubbles();
        }
      });
    });
  }

  void _resumeGame() {
    if (!_gameStarted || _gameOver) return;
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timeLeft -= 0.1;
        if (_timeLeft <= 0) {
          _endGame();
          timer.cancel();
        } else {
          _spawnBubble();
          _updateBubbles();
        }
      });
    });
  }

  void _spawnBubble() {
    if (_bubbles.length < 5 + _level && Random().nextDouble() < 0.2) {
      final bubbleTypes = ['Eczema', 'Acne', 'Ashy Skin'];
      _bubbles.add(Bubble(
        position: Offset(50 + Random().nextDouble() * 200, 400),
        type: bubbleTypes[Random().nextInt(bubbleTypes.length)],
        speed: 1 + _level * 0.2,
      ));
    }
  }

  void _updateBubbles() {
    for (var bubble in List.from(_bubbles)) {
      bubble.position = Offset(bubble.position.dx, bubble.position.dy - bubble.speed);
      if (bubble.position.dy < 0) {
        _bubbles.remove(bubble);
      }
    }
  }

  void _handlePop(Bubble bubble) {
    if (_gameOver || _selectedTool.isEmpty || _showTooltip || _showGestureDemo) return;

    setState(() {
      if (tools.firstWhere((t) => t['name'] == _selectedTool)['cures'] == bubble.type) {
        _bubbles.remove(bubble);
        _score += 10;
      } else {
        _bubbles.remove(bubble);
        _score -= 5;
      }
      _selectedTool = '';
      // Reset the animation for the previously selected tool
      if (_selectedTool.isNotEmpty) {
        _toolAnimationControllers[_selectedTool]?.reverse();
      }
    });
  }

  void _endGame() {
    setState(() {
      _gameOver = true;
    });

    if (_blocContext != null) {
      _blocContext!.read<SaveGameScoreBloc>().add(SaveGameScoreSubmitted(score: _score));
    } else {
      print('Error: _blocContext is null. Cannot submit score.');
    }
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _gameStarted = false;
      _gameOver = false;
      _showTooltip = true;
      _bubbles.clear();
      _score = 0;
      _timeLeft = 60.0;
      _startGestureDemo();
    });
  }

  void _toggleTooltip() {
    setState(() {
      if (_showTooltip || _showGestureDemo) {
        _showTooltip = false;
        _showGestureDemo = false;
        _fingerController.stop();
        if (_gameStarted) _resumeGame();
      } else {
        _gameTimer.cancel();
        _startGestureDemo();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _fingerController.dispose();
    _toolAnimationControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SaveGameScoreBloc>(
      create: (context) => SaveGameScoreBloc(repository: getIt<GameScoreRepository>()),
      child: Builder(
        builder: (BuildContext newContext) {
          _blocContext = newContext;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF40C4FF),
              title: const Text('Skincare Pop!', style: TextStyle(color: Colors.white)),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.white),
                  onPressed: _toggleTooltip,
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF40C4FF), Color(0xFFCE93D8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: WavePainter())),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Score: $_score',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Time: ${_timeLeft.toStringAsFixed(1)}s',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: _bubbles.map((bubble) => Positioned(
                          left: bubble.position.dx,
                          top: bubble.position.dy,
                          child: GestureDetector(
                            onTap: () => _handlePop(bubble),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.8),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  bubble.type == 'Eczema'
                                      ? Media.eczemaIcon
                                      : bubble.type == 'Acne'
                                      ? Media.acneIcon
                                      : Media.ashySkinIcon,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: tools.asMap().entries.map((entry) {
                        final index = entry.key;
                        final tool = entry.value;
                        final isSelected = _selectedTool == tool['name'];
                        final animationController = _toolAnimationControllers[tool['name']]!;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // Reset the animation for the previously selected tool
                                if (_selectedTool.isNotEmpty && _selectedTool != tool['name']) {
                                  _toolAnimationControllers[_selectedTool]?.reverse();
                                }
                                _selectedTool = tool['name'];
                                // Play the animation for the newly selected tool
                                animationController.forward(from: 0);
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow effect during tutorial
                                if (_showGestureDemo && _tutorialStep % 2 == 0 && _tutorialStep ~/ 2 == index)
                                  AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.yellow.withOpacity(_glowAnimation.value * 0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                // Scale animation for the selected tool
                                ScaleTransition(
                                  scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                                    CurvedAnimation(
                                      parent: animationController,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? tool['color'].withOpacity(0.9)
                                          : tool['color'].withOpacity(0.6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.8) // White glow for selected tool
                                              : tool['color'].withOpacity(0.5),
                                          blurRadius: isSelected ? 15 : 10,
                                          spreadRadius: isSelected ? 2 : 0,
                                        ),
                                      ],
                                      border: isSelected
                                          ? Border.all(color: Colors.white, width: 3) // White border for selected tool
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          tool['icon'],
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_showTooltip)
                    Center(
                      child: Container(
                        width: 320,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFF40C4FF)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'How to Play',
                              style: TextStyle(color: Color(0xFF40C4FF), fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: tools.map((tool) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(tool['icon'], color: Colors.white, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${tool['name']} pops ${tool['cures']}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 5),
                                    ClipOval(
                                      child: Image.asset(
                                        tool['image'],
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _showTooltip = false;
                                  _fingerController.stop();
                                  if (!_gameStarted) {
                                    _startGame();
                                  } else {
                                    _resumeGame();
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6F61),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Got It!', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_showGestureDemo) ...[
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            SizedBox(width: 10),
                            Column(
                              children: [
                                Text(
                                  'Please Wait...',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Watch the demo!',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _fingerAnimation,
                      builder: (context, child) {
                        final toolIndex = _tutorialStep ~/ 2;
                        final isToolTap = _tutorialStep % 2 == 0;
                        return Stack(
                          children: [
                            Positioned(
                              left: _fingerAnimation.value.dx - 20,
                              top: _fingerAnimation.value.dy - 60,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  isToolTap
                                      ? 'Tap ${tools[toolIndex]['name']}'
                                      : 'Pop ${tools[toolIndex]['cures']} Bubble',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            Positioned(
                              left: _fingerAnimation.value.dx - 20,
                              top: _fingerAnimation.value.dy - 20,
                              child: const Icon(Icons.touch_app, color: Colors.yellow, size: 40),
                            ),
                          ],
                        );
                      },
                    ),
                    if (_tutorialStep % 2 == 1 && _tutorialStep < 6)
                      Positioned(
                        left: 150,
                        top: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(_glowAnimation.value * 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  _tutorialStep == 1
                                      ? Media.eczemaIcon
                                      : _tutorialStep == 3
                                      ? Media.acneIcon
                                      : Media.ashySkinIcon,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if (_gameOver)
                    BlocConsumer<SaveGameScoreBloc, SaveGameScoreState>(
                      listener: (context, state) {
                        if (state is SaveGameScoreFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving score: ${state.error}')),
                          );
                        }
                      },
                      builder: (context, state) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Time’s Up!',
                                  style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Score: $_score',
                                  style: const TextStyle(color: Colors.white, fontSize: 24),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Tip: ${tools[_level % 3]['name']} fixes ${tools[_level % 3]['cures']}!',
                                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (state is SaveGameScoreLoading)
                                  const CircularProgressIndicator(color: Colors.white),
                                if (state is! SaveGameScoreLoading) ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider<LeaderboardBloc>(
                                            create: (context) => LeaderboardBloc(repository: getIt<GameScoreRepository>()),
                                            child: const LeaderboardPage(fromGame: true),
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF40C4FF),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: const Text('See Leaderboard', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Bubble {
  Offset position;
  String type;
  double speed;

  Bubble({required this.position, required this.type, required this.speed});
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7, size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}