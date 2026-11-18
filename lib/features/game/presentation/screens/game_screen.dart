import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/features/game/presentation/widgets/game_header.dart';
import 'package:melocue/features/game/presentation/widgets/snippet_progression.dart';
import 'package:melocue/features/game/presentation/widgets/guess_input_field.dart';
import 'package:melocue/features/game/presentation/widgets/logo_loader.dart';
import 'package:melocue/features/game/presentation/widgets/guess_history_list.dart';
import 'package:melocue/features/game/presentation/widgets/vinyl_visualizer.dart';
import 'package:melocue/features/game/presentation/widgets/hint_boxes.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/core/services/ad_service.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:melocue/core/presentation/widgets/shake_widget.dart';
import 'package:melocue/core/presentation/widgets/flash_overlay_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  GameReady? _lastReadyState;
  int _lastPastGuessesCount = 0;
  int _lastSessionHistoryCount = 0;
  late GameBloc _gameBloc;
  bool _shakeInput = false;
  bool _flashRed = false;
  bool _flashGreen = false;

  @override
  void initState() {
    super.initState();
    _gameBloc = context.read<GameBloc>();
    WidgetsBinding.instance.addObserver(this);
    // Start default game ONLY if it hasn't been started yet
    if (_gameBloc.state is GameInitial) {
      _gameBloc.add(const GameStarted(mode: GameMode.endless));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // When screen is closed, pause any playing audio
    _gameBloc.add(PauseRequested());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _gameBloc.add(PauseRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: BlocConsumer<GameBloc, GameState>(
          listener: (context, state) {
            if (state is GameError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: context.colors.error,
                ),
              );
            } else if (state is GameOver) {
              context.goNamed(RouteNames.result, extra: state);
            } else if (state is GameReady) {
              if (state.pastGuesses.length > _lastPastGuessesCount) {
                final lastGuess = state.pastGuesses.last;
                if (lastGuess.isNotEmpty) {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    _shakeInput = true;
                    _flashRed = true;
                  });
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) setState(() { _shakeInput = false; _flashRed = false; });
                  });
                  _showNotification(
                    context,
                    context.l10n.wrongGuess,
                    isSuccess: false,
                  );
                }
              }
              _lastPastGuessesCount = state.pastGuesses.length;

              if (state.sessionHistory.length > _lastSessionHistoryCount) {
                if (state.sessionHistory.isNotEmpty) {
                  final lastItem = state.sessionHistory.first; // We insert at 0
                  if (lastItem.isVictory) {
                    HapticFeedback.heavyImpact();
                    setState(() {
                      _flashGreen = true;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) setState(() { _flashGreen = false; });
                    });
                    _showNotification(
                      context,
                      context.l10n.correctGuess,
                      isSuccess: true,
                    );
                  }
                }
              }
              _lastSessionHistoryCount = state.sessionHistory.length;
            } else if (state is GameReviveOffer) {
              _showReviveBottomSheet(context, state);
            }
          },
          builder: (context, state) {
            if (state is GameInitial || state is GameLoading) {
              return const Center(child: LogoLoader(size: 100.0));
            }

            if (state is GameError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.failure.message,
                      style: context.typography.bodyLarge?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                    16.h,
                    ElevatedButton(
                      onPressed: () => context.read<GameBloc>().add(
                        const GameStarted(mode: GameMode.endless),
                      ),
                      child: Text(
                        context.l10n.playButton,
                      ), // using localization
                    ),
                  ],
                ),
              );
            }

            if (state is GameReady) {
              _lastReadyState = state;
            }

            if (_lastReadyState != null) {
              return _buildGameUI(
                context,
                _lastReadyState!,
                isGameOver: state is GameOver,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      // The bottomNavigationBar is now handled by MainScaffold
    );
  }

  Widget _buildGameUI(
    BuildContext context,
    GameReady state, {
    bool isGameOver = false,
  }) {
    return FlashOverlayWidget(
      flashRed: _flashRed,
      flashGreen: _flashGreen,
      child: SingleChildScrollView(
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
        child: Column(
          children: [
            16.h,
            GameHeader(
              streak: state.streak,
              mode: state.mode,
              modeParameter: state.modeParameter,
            ),
            24.h,
            VinylVisualizer(
              albumArtUrl: state.currentTrack.albumArtUrl,
              isPlaying: state.isPlaying && !isGameOver,
              isBlurred: !isGameOver,
              positionStream: context
                  .read<GameBloc>()
                  .audioPlayerService
                  .positionStream,
              currentChunkDuration: state.currentChunkDuration,
            ),
            16.h,
            HintBoxes(
              trackName: state.currentTrack.trackName,
              artistName: state.currentTrack.artistName,
              revealedIndices: state.revealedHintIndices,
              hasRevealedArtist: state.hasRevealedArtist,
            ),
            32.h,
            SnippetProgression(
              currentChunkIndex: state.currentChunkIndex,
              chunks: state.chunks,
              pastGuesses: state.pastGuesses,
            ),
            16.h,
            GuessHistoryList(sessionHistory: state.sessionHistory),
            16.h,
            16.h,
            if (!isGameOver)
              ShakeWidget(
                shouldShake: _shakeInput,
                child: GuessInputField(
                  onSubmit: (guess) {
                    if (guess.trim().isEmpty) {
                      context.read<GameBloc>().add(GiveUpRequested());
                    } else {
                      context.read<GameBloc>().add(GuessSubmitted(guess));
                    }
                  },
                ),
              ),
            16.h,
          ],
        ),
        ),
      ),
    );
  }

  void _showNotification(
    BuildContext context,
    String message, {
    bool isSuccess = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    final bgColor = isSuccess
        ? const Color(0xFF1ED760)
        : const Color(0xFFE91429);
    final icon = isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.close_rounded;
    final textColor = isSuccess ? Colors.black : Colors.white;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: -100.0, end: 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(offset: Offset(0, value), child: child);
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: bgColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: textColor),
                  12.w,
                  Expanded(
                    child: Text(
                      message,
                      style: context.typography.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showReviveBottomSheet(BuildContext context, GameReviveOffer state) {
    bool didRevive = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF151219),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFE91429),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Pes Etme!',
                style: context.typography.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bir şansın daha var. Reklam izleyerek veya Coin harcayarak oyuna geri dön.',
                textAlign: TextAlign.center,
                style: context.typography.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final adService = context.read<AdService>();
                  if (adService.isAdLoaded) {
                    adService.showRewardedAd(
                      onUserEarnedReward: () {
                        didRevive = true;
                        Navigator.pop(bottomSheetContext);
                        context.read<GameBloc>().add(
                          ReviveAccepted(state.previousState),
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reklam henüz yüklenmedi, lütfen tekrar deneyin.',
                        ),
                      ),
                    );
                    adService.loadRewardedAd();
                  }
                },
                icon: const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.black,
                ),
                label: const Text(
                  'Ücretsiz Devam Et',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1ED760),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final storage = context.read<LocalStorageService>();
                  final success = await storage.deductCoins(50);
                  if (!bottomSheetContext.mounted || !context.mounted) return;

                  if (success) {
                    didRevive = true;
                    Navigator.pop(bottomSheetContext);
                    context.read<GameBloc>().add(
                      ReviveAccepted(state.previousState),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Yetersiz Coin!')),
                    );
                  }
                },
                icon: const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFFFFD700),
                ),
                label: const Text(
                  '50 Coin İle Devam Et',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD700)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(bottomSheetContext);
                },
                child: const Text(
                  'Vazgeç',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (!didRevive && context.mounted) {
        context.read<GameBloc>().add(ReviveDeclined(state.previousState));
      }
    });
  }
}
