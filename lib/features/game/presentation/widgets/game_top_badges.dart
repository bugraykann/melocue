import 'package:flutter/material.dart';
import 'package:melocue/core/utils/context_extensions.dart';

class GameTopBadges extends StatelessWidget {
  final String currentSnippetText;
  final int currentAttempt;
  final int maxAttempts;

  const GameTopBadges({
    super.key,
    required this.currentSnippetText,
    required this.currentAttempt,
    required this.maxAttempts,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          context,
          icon: Icons.circle,
          iconColor: const Color(0xFF1ED760),
          iconSize: 10,
          text: context.l10n.dailyBadgeText(184),
          textColor: const Color(0xFF1ED760),
          bgColor: const Color(0xFF1C2220),
        ),
        _buildBadge(
          context,
          icon: Icons.timer_outlined,
          iconColor: const Color(0xFFB3B3B3),
          iconSize: 14,
          text: context.l10n.snippetDuration(currentSnippetText),
          textColor: const Color(0xFFB3B3B3),
          bgColor: const Color(0xFF1A1A1E),
        ),
        _buildBadge(
          context,
          text: context.l10n.guessCountText(currentAttempt, maxAttempts),
          textColor: const Color(0xFFD4B3F7),
          bgColor: const Color(0xFF2C2436),
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    IconData? icon,
    Color? iconColor,
    double? iconSize,
    required String text,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: context.typography.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
