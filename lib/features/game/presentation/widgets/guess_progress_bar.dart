import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';

class GuessProgressBar extends StatelessWidget {
  final List<Duration> chunks;
  final int currentChunkIndex;
  final List<String> pastGuesses;

  const GuessProgressBar({
    super.key,
    required this.chunks,
    required this.currentChunkIndex,
    required this.pastGuesses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.snippetProgression,
              style: context.typography.labelMedium?.copyWith(
                color: context.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              context.l10n.stageProgression(currentChunkIndex + 1, chunks.length),
              style: context.typography.bodySmall?.copyWith(
                color: context.colors.tertiaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        8.h,
        Row(
          children: List.generate(chunks.length, (index) {
            final isPast = index < currentChunkIndex;
            final isCurrent = index == currentChunkIndex;
            
            Color bgColor = context.surfaceContainer;
            Color textColor = context.onSurfaceVariant.withValues(alpha: 0.5);
            IconData icon = Icons.lock;

            if (isPast) {
              bgColor = context.colors.error.withValues(alpha: 0.25);
              textColor = context.colors.error;
              icon = Icons.close;
            } else if (isCurrent) {
              bgColor = context.colors.tertiaryContainer.withValues(alpha: 0.3);
              textColor = context.tertiaryFixed;
              icon = Icons.headphones;
            }

            final secs = chunks[index].inMilliseconds / 1000;
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: textColor),
                    2.h,
                    Text(
                      '${secs}s',
                      style: context.typography.labelSmall?.copyWith(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
