// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/data/models/emoji_levels_data.dart';
import 'package:melocue/features/game/presentation/widgets/coin_display.dart';

class EmojiStagesScreen extends StatefulWidget {
  const EmojiStagesScreen({super.key});

  @override
  State<EmojiStagesScreen> createState() => _EmojiStagesScreenState();
}

class _EmojiStagesScreenState extends State<EmojiStagesScreen>
    with TickerProviderStateMixin {
  late AnimationController _pathController;
  late Animation<double> _pathAnimation;

  // Shake animation map for each locked node
  final Map<int, AnimationController> _shakeControllers = {};

  int totalStages = 0;
  bool isLoading = true;
  final double nodeSize = 80.0;
  final double verticalPadding = 32.0;

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pathAnimation = CurvedAnimation(
      parent: _pathController,
      curve: Curves.easeInOutCubic,
    );

    _loadData();
  }

  Future<void> _loadData() async {
    final storage = context.read<LocalStorageService>();
    final stages = await loadEmojiStagesData(storage.countryCode);
    if (mounted) {
      setState(() {
        totalStages = stages.length;
        isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pathController.forward();
      });
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    for (var controller in _shakeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _triggerShake(int stageNum) {
    if (!_shakeControllers.containsKey(stageNum)) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _shakeControllers[stageNum] = controller;
    }

    final controller = _shakeControllers[stageNum]!;
    controller.forward(from: 0.0).then((_) => controller.reset());
  }

  double _getAlignmentForStage(int stageNum) {
    // Stage 1 (bottom) to Stage 10 (top)
    // 1 -> 0.0
    // 2 -> 0.6
    // 3 -> 0.0
    // 4 -> -0.6
    int indexFromBottom = stageNum - 1;
    if (indexFromBottom % 4 == 1) return 0.6;
    if (indexFromBottom % 4 == 3) return -0.6;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<LocalStorageService>();
    final itemHeight = nodeSize + (verticalPadding * 2);

    return ListenableBuilder(
      listenable: storage.emojiUnlockedNotifier,
      builder: (context, _) {
        final unlockedStages = storage.emojiUnlockedNotifier.value;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              context.l10n.emojiModeTitle,
              style: context.typography.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(child: CoinDisplay()),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Statistics Banner
                _buildTopStatsBanner(unlockedStages),

                // Scrollable Map Area
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1ED760),
                          ),
                        )
                      : SingleChildScrollView(
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Stack(
                        children: [
                          // Animated Path
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _pathAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: CurvedPathPainter(
                                    totalStages: totalStages,
                                    itemHeight: itemHeight,
                                    nodeSize: nodeSize,
                                    progress: _pathAnimation.value,
                                    unlockedStages: unlockedStages,
                                    getAlignment: _getAlignmentForStage,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Nodes
                          Column(
                            children: List.generate(totalStages, (index) {
                              // index 0 is Stage 10, index 9 is Stage 1
                              final stageNum = totalStages - index;
                              final isPremiumLocked =
                                  stageNum >= 5 && !storage.hasPremiumEmojiPass;
                              final isReached = stageNum <= unlockedStages;
                              final isUnlocked = isReached && !isPremiumLocked;
                              final isCurrent =
                                  stageNum == storage.currentEmojiStage;

                              final alignment = _getAlignmentForStage(stageNum);

                              // Shake animation setup
                              Animation<double>? shakeAnimation;
                              if (_shakeControllers.containsKey(stageNum)) {
                                shakeAnimation =
                                    TweenSequence<double>([
                                      TweenSequenceItem(
                                        tween: Tween(begin: 0.0, end: -10.0),
                                        weight: 1,
                                      ),
                                      TweenSequenceItem(
                                        tween: Tween(begin: -10.0, end: 10.0),
                                        weight: 2,
                                      ),
                                      TweenSequenceItem(
                                        tween: Tween(begin: 10.0, end: -10.0),
                                        weight: 2,
                                      ),
                                      TweenSequenceItem(
                                        tween: Tween(begin: -10.0, end: 10.0),
                                        weight: 2,
                                      ),
                                      TweenSequenceItem(
                                        tween: Tween(begin: 10.0, end: 0.0),
                                        weight: 1,
                                      ),
                                    ]).animate(
                                      CurvedAnimation(
                                        parent: _shakeControllers[stageNum]!,
                                        curve: Curves.easeInOut,
                                      ),
                                    );
                              }

                              Widget nodeWidget = Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: verticalPadding,
                                ),
                                child: Align(
                                  alignment: Alignment(alignment, 0.0),
                                  child: _buildStageNode(
                                    context: context,
                                    stageNum: stageNum,
                                    isUnlocked: isUnlocked,
                                    isCurrent: isCurrent,
                                    isPremiumLocked: isPremiumLocked,
                                    isReached: isReached,
                                    onTap: () => _handleStageTap(
                                      stageNum,
                                      isUnlocked,
                                      isPremiumLocked,
                                      isReached,
                                      storage,
                                    ),
                                  ),
                                ),
                              );

                              if (shakeAnimation != null) {
                                return AnimatedBuilder(
                                  animation: shakeAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(shakeAnimation!.value, 0),
                                      child: child,
                                    );
                                  },
                                  child: nodeWidget,
                                );
                              }

                              return nodeWidget;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopStatsBanner(int unlockedStages) {
    if (totalStages == 0) return const SizedBox();

    int completedStages = (unlockedStages - 1).clamp(0, totalStages);
    double completionPercentage = (completedStages / totalStages) * 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1ED760).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1ED760).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFF1ED760),
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Emoji Master",
                  style: context.typography.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tamamlanan: $completedStages / $totalStages",
                  style: context.typography.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completedStages / totalStages,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1ED760),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "%${completionPercentage.toInt()}",
            style: context.typography.titleLarge?.copyWith(
              color: const Color(0xFF1ED760),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageNode({
    required BuildContext context,
    required int stageNum,
    required bool isUnlocked,
    required bool isCurrent,
    required bool isPremiumLocked,
    required bool isReached,
    required VoidCallback onTap,
  }) {
    Color nodeColor;
    if (isCurrent) {
      nodeColor = const Color(0xFF1ED760); // Current active is prominent green
    } else if (isUnlocked) {
      nodeColor = const Color(0xFF1ED760)
          .withValues(alpha: 0.5); // Finished is dimmed green
    } else {
      nodeColor = const Color(0xFF2A2A35);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF151219),
              border: Border.all(color: nodeColor, width: isCurrent ? 4 : 2),
              boxShadow: isCurrent || isUnlocked
                  ? [
                      BoxShadow(
                        color: nodeColor.withValues(
                          alpha: isCurrent ? 0.6 : 0.2,
                        ),
                        blurRadius: isCurrent ? 24 : 12,
                        spreadRadius: isCurrent ? 8 : 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isPremiumLocked
                  ? const Icon(Icons.lock, color: Colors.amber, size: 32)
                  : !isReached
                  ? const Icon(
                      Icons.lock_outline,
                      color: Colors.white24,
                      size: 32,
                    )
                  : Text(
                      stageNum.toString(),
                      style: context.typography.headlineSmall?.copyWith(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          if (isPremiumLocked)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '200',
                    style: context.typography.bodySmall?.copyWith(
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleStageTap(
    int stageNum,
    bool isUnlocked,
    bool isPremiumLocked,
    bool isReached,
    LocalStorageService storage,
  ) async {
    if (isPremiumLocked) {
      _triggerShake(stageNum);
      _showUnlockDialog(stageNum, storage);
      return;
    }

    if (!isReached) {
      _triggerShake(stageNum);
      return;
    }

    if (isUnlocked) {
      await storage.saveCurrentEmojiStage(stageNum);
      await storage.saveCurrentEmojiIndex(0);
      if (mounted) {
        await context.pushNamed(RouteNames.emojiGame);
        setState(() {});
        // Restart animation to draw newly unlocked paths
        _pathController.forward(from: 0.0);
      }
    }
  }

  void _showUnlockDialog(int stageNum, LocalStorageService storage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Kilitli Bölüm', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Bu bölümü açmak için 200 Altın gerekiyor. Açmak ister misin?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (storage.coins >= 200) {
                await storage.deductCoins(200);
                await storage.setPremiumEmojiPass(true);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  _pathController.forward(from: 0.0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kilit Açıldı!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yeterli altınınız yok!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '200 Altın Öde',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CurvedPathPainter extends CustomPainter {
  final int totalStages;
  final double itemHeight;
  final double nodeSize;
  final double progress; // 0.0 to 1.0 animation progress
  final int unlockedStages;
  final double Function(int) getAlignment;

  CurvedPathPainter({
    required this.totalStages,
    required this.itemHeight,
    required this.nodeSize,
    required this.progress,
    required this.unlockedStages,
    required this.getAlignment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = const Color(0xFF1ED760).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = const Color(0xFF1ED760)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final fullPath = Path();

    // Nodes are in a Column with index 0 at the top (Stage 10).
    // The visual top of the stack is y = 0.
    // Stage 1 (bottom) is at y = totalHeight - (itemHeight/2).
    // Stage N center Y is: (totalStages - stageN) * itemHeight + (itemHeight / 2)

    double getCenterY(int stage) {
      int indexFromTop = totalStages - stage;
      return indexFromTop * itemHeight + (itemHeight / 2);
    }

    double getCenterX(int stage) {
      double align = getAlignment(stage);
      double availableWidth = size.width - nodeSize;
      return (availableWidth / 2) * align + (size.width / 2);
    }

    // Move to bottom (Stage 1)
    fullPath.moveTo(getCenterX(1), getCenterY(1));

    // Draw curves upwards to Stage 10
    for (int i = 1; i < totalStages; i++) {
      double startX = getCenterX(i);
      double startY = getCenterY(i);
      double endX = getCenterX(i + 1);
      double endY = getCenterY(i + 1);

      double controlPointY1 = startY - (itemHeight / 2);
      double controlPointY2 = endY + (itemHeight / 2);

      fullPath.cubicTo(
        startX,
        controlPointY1,
        endX,
        controlPointY2,
        endX,
        endY,
      );
    }

    // Draw the subtle background path completely
    canvas.drawPath(fullPath, paint);

    // Now extract and draw the animated active path up to the current unlocked level
    // Max level we can draw brightly is unlockedStages (if > total, clamp to total).
    final maxActiveStage = unlockedStages.clamp(1, totalStages);

    // We calculate what percentage of the total path length corresponds to the unlocked stages.
    // Since each stage segment is roughly equal length, we can approximate:
    double targetSegmentRatio = (maxActiveStage - 1) / (totalStages - 1);

    // Only animate up to the target segment
    double currentDrawRatio = targetSegmentRatio * progress;

    if (currentDrawRatio > 0) {
      PathMetrics pathMetrics = fullPath.computeMetrics();
      for (PathMetric pathMetric in pathMetrics) {
        final extractLength = pathMetric.length * currentDrawRatio;
        final animatedPath = pathMetric.extractPath(0.0, extractLength);

        // Add glow to the active path
        canvas.drawPath(
          animatedPath,
          Paint()
            ..color = const Color(0xFF1ED760).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        // Draw crisp solid inner path
        canvas.drawPath(animatedPath, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CurvedPathPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.unlockedStages != unlockedStages;
  }
}
