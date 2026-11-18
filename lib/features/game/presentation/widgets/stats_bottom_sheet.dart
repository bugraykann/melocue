import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

class StatsBottomSheet extends StatelessWidget {
  const StatsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.read<LocalStorageService>();

    final int gamesPlayed = stats.gamesPlayed;
    final int gamesWon = stats.gamesWon;
    final int currentStreak = stats.currentStreak;
    final int maxStreak = stats.maxStreak;

    final double winRate = gamesPlayed == 0
        ? 0
        : (gamesWon / gamesPlayed) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF181820),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          24.h,

          Text(
            context.l10n.statisticsUpper,
            style: context.typography.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          32.h,

          // Stats Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: context.l10n.playedLabel,
                value: gamesPlayed.toString(),
              ),
              _StatItem(
                label: context.l10n.winPercentageLabel,
                value: winRate.toStringAsFixed(0),
              ),
              _StatItem(
                label: context.l10n.currentStreakLabel,
                value: currentStreak.toString(),
              ),
              _StatItem(
                label: context.l10n.maxStreakLabel,
                value: maxStreak.toString(),
              ),
            ],
          ),

          32.h,

          // Win Rate Visual
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  context.l10n.winRate,
                  style: context.typography.titleMedium?.copyWith(
                    color: const Color(0xFFB3B3B3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                16.h,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: gamesPlayed == 0 ? 0 : (gamesWon / gamesPlayed),
                        strokeWidth: 10,
                        backgroundColor: const Color(0xFF181820),
                        color: const Color(0xFF1ED760),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${winRate.toStringAsFixed(0)}%',
                      style: context.typography.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          48.h,
          MediaQuery.of(context).padding.bottom.h,
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.typography.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        8.h,
        Text(
          label,
          textAlign: TextAlign.center,
          style: context.typography.labelSmall?.copyWith(
            color: const Color(0xFFB3B3B3),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
