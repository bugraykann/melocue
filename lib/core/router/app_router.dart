import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:melocue/features/game/presentation/screens/game_screen.dart';
import 'package:melocue/features/game/presentation/screens/modes_screen.dart';
import 'package:melocue/features/game/presentation/screens/ranks_screen.dart';
import 'package:melocue/features/game/presentation/screens/settings_screen.dart';
import 'package:melocue/features/game/presentation/screens/game_result_screen.dart';
import 'package:melocue/features/game/presentation/screens/main_scaffold.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/features/game/presentation/screens/stats_screen.dart';
import 'package:melocue/features/game/presentation/screens/emoji_stages_screen.dart';
import 'package:melocue/features/game/presentation/screens/emoji_game_screen.dart';
import 'package:melocue/features/game/presentation/screens/emoji_stage_result_screen.dart';

class _FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _FadeIndexedStack({
    required this.index,
    required this.children,
  });

  @override
  _FadeIndexedStackState createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: IndexedStack(
        index: widget.index,
        children: widget.children,
      ),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/modes', // Start at Modes Screen
  routes: [
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return _FadeIndexedStack(
          index: navigationShell.currentIndex,
          children: children,
        );
      },
      branches: [
        // Branch 0: Modes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/modes',
              name: RouteNames.modes,
              builder: (context, state) => const ModesScreen(),
            ),
          ],
        ),
        // Branch 1: Ranks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ranks',
              name: RouteNames.ranks,
              builder: (context, state) => const RanksScreen(),
            ),
          ],
        ),
        // Branch 2: Play (Center FAB)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/game',
              name: RouteNames.game,
              builder: (context, state) => const GameScreen(),
            ),
          ],
        ),
        // Branch 3: Stats
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              name: RouteNames.stats,
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        // Branch 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: RouteNames.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/result',
      name: RouteNames.result,
      pageBuilder: (context, state) {
        final gameOverState = state.extra as GameOver;
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameResultScreen(state: gameOverState),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emoji-stages',
      name: RouteNames.emojiStages,
      builder: (context, state) => const EmojiStagesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emoji-game',
      name: RouteNames.emojiGame,
      builder: (context, state) => const EmojiGameScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emoji-stage-result',
      name: 'emojiStageResult',
      builder: (context, state) {
        final stageNumber = state.extra as int;
        return EmojiStageResultScreen(stageNumber: stageNumber);
      },
    ),
  ],
);
