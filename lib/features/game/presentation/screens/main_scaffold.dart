import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:go_router/go_router.dart';
import 'package:melocue/core/utils/context_extensions.dart';

import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/core/presentation/widgets/animated_game_background.dart';
import 'package:melocue/core/presentation/widgets/pulsing_glow_widget.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    // Add haptic feedback for better feel
    HapticFeedback.lightImpact();

    if (index == 2 && navigationShell.currentIndex == 2) {
      final state = context.read<GameBloc>().state;
      if (state is GameReady && !state.isPlaying) {
        context.read<GameBloc>().add(PlayChunkRequested());
      }
    } else {
      // If we are leaving the game screen, pause the audio
      if (navigationShell.currentIndex == 2) {
        context.read<GameBloc>().add(PauseRequested());
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameBloc>().state;
    final bool isPlaying = gameState is GameReady && gameState.isPlaying;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: AnimatedGameBackground(child: navigationShell),
      extendBody: true, // Allows the body to go behind the bottom app bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Transform.rotate(
        angle: 45 * math.pi / 180, // Diamond shape
        child: PulsingGlowWidget(
          glowColor: const Color(0xFF1ED760),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1ED760).withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              borderRadius: BorderRadius.circular(16),
            ),
            child: FloatingActionButton(
              onPressed: isPlaying
                  ? null
                  : () => _onTap(context, 2), // 2 is the Play tab index
              backgroundColor: const Color(0xFF1ED760),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Transform.rotate(
                angle:
                    -45 *
                    math.pi /
                    180, // Counter-rotate icon so it stays upright
                child: Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomAppBar(
          color: const Color(0xFF151219),
          shape: const CircularNotchedRectangle(),
          notchMargin: 10,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.grid_view_rounded,
                  label: context.l10n.navModes,
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.leaderboard_rounded,
                  label: context.l10n.navRanks,
                  index: 1,
                ),
                const SizedBox(width: 48), // Space for FAB
                _buildNavItem(
                  context,
                  icon: Icons.person_pin_rounded,
                  label: context.l10n.navStats,
                  index: 3,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: context.l10n.navSettings,
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = navigationShell.currentIndex == index;
    final color = isSelected
        ? const Color(0xFF1ED760)
        : const Color(0xFF888888);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context, index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(top: isSelected ? 0 : 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style:
                    context.typography.labelSmall?.copyWith(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: isSelected ? 11 : 10,
                    ) ??
                    TextStyle(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: isSelected ? 11 : 10,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
