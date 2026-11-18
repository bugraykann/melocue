import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/domain/entities/session_history_item.dart';

class GuessHistoryList extends StatelessWidget {
  final List<SessionHistoryItem> sessionHistory;

  const GuessHistoryList({super.key, required this.sessionHistory});

  @override
  Widget build(BuildContext context) {
    if (sessionHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sessionHistory.map((item) {
        final durationStr =
            '${(item.finalDuration.inMilliseconds / 1000).toStringAsFixed(1)}s';

        final iconData = item.isVictory
            ? Icons.check_rounded
            : (item.isSkip ? Icons.fast_forward_rounded : Icons.close_rounded);

        final iconBgColor = item.isVictory
            ? const Color(0xFF1ED760).withValues(alpha: 0.1)
            : const Color(0xFF332025);

        final iconColor = item.isVictory
            ? const Color(0xFF1ED760)
            : (item.isSkip ? Colors.white : const Color(0xFFF6A4A0));

        final subtitle = item.isVictory
            ? context.l10n.correctlyGuessed
            : (item.isSkip ? context.l10n.skipped : context.l10n.wronglyGuessed);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B22),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 16),
              ),
              12.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.track.artistName} • ${item.track.trackName}',
                      style: context.typography.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.h,
                    Text(
                      subtitle,
                      style: context.typography.labelMedium?.copyWith(
                        color: item.isVictory
                            ? const Color(0xFF1ED760)
                            : (item.isSkip
                                  ? const Color(0xFFB3B3B3)
                                  : const Color(0xFFF6A4A0)),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                durationStr,
                style: context.typography.labelMedium?.copyWith(
                  color: const Color(0xFFB3B3B3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
