import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';

class SnippetProgression extends StatelessWidget {
  final int currentChunkIndex;
  final List<Duration> chunks;
  final List<String> pastGuesses;
  final bool isGameOver;
  final int? winningChunkIndex;

  const SnippetProgression({
    super.key,
    required this.currentChunkIndex,
    required this.chunks,
    required this.pastGuesses,
    this.isGameOver = false,
    this.winningChunkIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.snippetProgression,
              style: context.typography.labelMedium?.copyWith(
                color: const Color(0xFFB3B3B3),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              context.l10n.stageProgression(currentChunkIndex + 1, chunks.length),
              style: context.typography.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF9C74F),
              ),
            ),
          ],
        ),
        12.h,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(chunks.length, (index) {
            final durationStr = index < 2
                ? '${(chunks[index].inMilliseconds / 1000).toStringAsFixed(1)}s'
                : '${(chunks[index].inMilliseconds / 1000).toStringAsFixed(1).replaceAll('.0', '')}s';

            final isPast = index < currentChunkIndex;
            final isCurrent = index == currentChunkIndex && !isGameOver;

            final isWinning = isGameOver && winningChunkIndex == index;
            final isWrong =
                isPast &&
                (winningChunkIndex == null || index != winningChunkIndex);

            Color bgColor;
            Color textColor;
            IconData icon;
            Color iconColor;
            List<BoxShadow>? shadow;
            Border? border;

            if (isWinning) {
              bgColor = const Color(0xFF1ED760);
              textColor = Colors.black;
              iconColor = Colors.black;
              icon = Icons.check_rounded;
              shadow = [
                BoxShadow(
                  color: const Color(0xFF1ED760).withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ];
            } else if (isCurrent) {
              bgColor = const Color(0xFF3A2E24);
              textColor = const Color(0xFFF9C74F);
              iconColor = const Color(0xFFF9C74F);
              icon = Icons.headphones_rounded;
              shadow = [
                BoxShadow(
                  color: const Color(0xFFF9C74F).withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ];
              border = Border.all(color: const Color(0xFF5A4426));
            } else if (isWrong ||
                (isGameOver && !isWinning && index <= pastGuesses.length)) {
              bgColor = const Color(0xFF332025);
              textColor = const Color(0xFFF6A4A0);
              iconColor = const Color(0xFFF6A4A0);
              icon = Icons.close_rounded;
            } else {
              // Locked
              bgColor = const Color(0xFF1B1B22);
              textColor = const Color(0xFF666666);
              iconColor = const Color(0xFF666666);
              icon = Icons.lock_outline_rounded;
            }

            return Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: border,
                boxShadow: shadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  4.h,
                  Text(
                    durationStr,
                    style: context.typography.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: isCurrent || isWinning
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
