import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/widgets/stats_bottom_sheet.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showStats(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StatsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12), // Deep background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => _showStats(context),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // Logo Area
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primary.withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    20.h,
                        Text(
                          'MELOCUE',
                          style: context.typography.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            shadows: [
                              Shadow(
                                color: context.colors.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                    8.h,
                    Text(
                      context.l10n.subtitleTagline,
                      style: context.typography.bodyLarge?.copyWith(
                        color: const Color(0xFFB3B3B3),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Play Buttons
              ElevatedButton.icon(
                onPressed: () {
                  final localStorageService = context
                      .read<LocalStorageService>();
                  if (localStorageService.hasPlayedDailyToday) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.dailyChallengePlayed,
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    context.read<GameBloc>().add(
                      const GameStarted(mode: GameMode.daily),
                    );
                    context.go('/game');
                  }
                },
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.black,
                ),
                label: Text(
                  context.l10n.dailyChallenge,
                  style: context.typography.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      // bottomNavigationBar is handled by MainScaffold
    );
  }
}
