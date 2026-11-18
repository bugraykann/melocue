import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/presentation/widgets/coin_display.dart';

class GameHeader extends StatelessWidget {
  final int streak;
  final GameMode mode;
  final String? modeParameter;

  const GameHeader({
    super.key,
    required this.streak,
    required this.mode,
    this.modeParameter,
  });

  String _getModeName(BuildContext context) {
    switch (mode) {
      case GameMode.daily:
        return context.l10n.dailyChallenge;
      case GameMode.endless:
        return context.l10n.endlessMode;
      case GameMode.category:
        return modeParameter ?? context.l10n.category;
      case GameMode.fanTest:
        return context.l10n.fanTestTitle(modeParameter ?? '');
      case GameMode.myPlaylist:
        return context.l10n.myPlaylist;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // App Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              8.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Melocue',
                      style: context.typography.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getModeName(context),
                      style: context.typography.labelSmall?.copyWith(
                        color: const Color(0xFF1ED760),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const CoinDisplay(),
            8.w,
            // Streak Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1712),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF32231A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFF08C36), size: 18),
                  6.w,
                  Text(
                    streak.toString(),
                    style: context.typography.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
