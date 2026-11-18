import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';

class HintBoxes extends StatelessWidget {
  final String trackName;
  final String artistName;
  final Set<int> revealedIndices;
  final bool hasRevealedArtist;

  const HintBoxes({
    super.key,
    required this.trackName,
    required this.artistName,
    required this.revealedIndices,
    required this.hasRevealedArtist,
  });

  @override
  Widget build(BuildContext context) {
    // Group characters into words to prevent Wrap from breaking words in the middle
    final List<List<MapEntry<int, String>>> words = [];
    List<MapEntry<int, String>> currentWord = [];

    for (int i = 0; i < trackName.length; i++) {
      if (trackName[i] == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(currentWord);
          currentWord = [];
        }
      } else {
        currentWord.add(MapEntry(i, trackName[i]));
      }
    }
    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRevealedArtist) ...[
            Text(
              artistName.toUpperCase(),
              style: context.typography.titleLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: context.colors.primary.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 16, // Space between words
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: words.map((word) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: word.map((entry) {
              final index = entry.key;
              final char = entry.value;
              final isRevealed = revealedIndices.contains(index);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2), // Space between characters in a word
                child: SizedBox(
                  width: 22,
                  height: 32,
                  child: Center(
                    child: isRevealed
                        ? Text(
                            char.toUpperCase(),
                            style: context.typography.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: context.colors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.primary.withValues(alpha: 0.7),
                              boxShadow: [
                                BoxShadow(
                                  color: context.colors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
          ),
        ],
      ),
    );
  }
}
