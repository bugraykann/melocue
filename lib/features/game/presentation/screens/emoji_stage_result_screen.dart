import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

class EmojiStageResultScreen extends StatefulWidget {
  final int stageNumber;

  const EmojiStageResultScreen({super.key, required this.stageNumber});

  @override
  State<EmojiStageResultScreen> createState() => _EmojiStageResultScreenState();
}

class _EmojiStageResultScreenState extends State<EmojiStageResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // Ödülü ver: Her bölüm 50 Altın
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalStorageService>().addCoins(50);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    "TEBRİKLER!",
                    style: context.typography.displaySmall?.copyWith(
                      color: const Color(0xFF1ED760),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFF1ED760).withValues(alpha: 0.5),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Bölüm ${widget.stageNumber} Tamamlandı",
                    style: context.typography.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Big Emoji Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1ED760).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1ED760).withValues(alpha: 0.2),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        "🏆",
                        style: TextStyle(fontSize: 96),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // İstatistikler Kartı
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E28),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          context,
                          icon: Icons.star_rounded,
                          color: Colors.amber,
                          title: "Bölüm Başarısı",
                          value: "10/10",
                        ),
                        const Divider(color: Colors.white12, height: 32),
                        _buildStatRow(
                          context,
                          icon: Icons.timer_rounded,
                          color: Colors.blueAccent,
                          title: "Tahmin Süresi",
                          value: "Harika",
                        ),
                        const Divider(color: Colors.white12, height: 32),
                        _buildStatRow(
                          context,
                          icon: Icons.monetization_on_rounded,
                          color: const Color(0xFF1ED760),
                          title: "Kazanılan Ödül",
                          value: "+50 Altın",
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Next Stage Button
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed(RouteNames.emojiStages);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1ED760),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF1ED760).withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      "Sonraki Bölüme Geç",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.home),
                    child: const Text(
                      "Ana Sayfaya Dön",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Text(
          title,
          style: context.typography.titleMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: context.typography.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
