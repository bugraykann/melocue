// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_event.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_state.dart';
import 'package:melocue/features/game/presentation/widgets/guess_input_field.dart';
import 'package:melocue/features/game/presentation/widgets/logo_loader.dart';
import 'package:melocue/features/game/domain/services/audio_player_service.dart';
import 'package:melocue/core/router/route_names.dart';
import 'package:melocue/core/presentation/widgets/shake_widget.dart';
import 'package:melocue/core/presentation/widgets/flash_overlay_widget.dart';

class EmojiGameScreen extends StatefulWidget {
  const EmojiGameScreen({super.key});

  @override
  State<EmojiGameScreen> createState() => _EmojiGameScreenState();
}

class _EmojiGameScreenState extends State<EmojiGameScreen>
    with WidgetsBindingObserver {
  late AudioPlayerService _audioService;
  late EmojiGameBloc _emojiGameBloc;
  final bool _shakeInput = false;
  final bool _flashRed = false;
  final bool _flashGreen = false;

  @override
  void initState() {
    super.initState();
    _audioService = context.read<AudioPlayerService>();
    _emojiGameBloc = context.read<EmojiGameBloc>();
    WidgetsBinding.instance.addObserver(this);
    // Always dispatch started to reload question (especially when coming from StageCompleted state)
    _emojiGameBloc.add(EmojiGameStarted());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.pause();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audioService.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<EmojiGameBloc, EmojiGameState>(
          listener: (context, state) async {
            final audioService = context.read<AudioPlayerService>();

            if (state is EmojiGameCorrect) {
              if (state.track != null) {
                await audioService.load(state.track!.previewUrl);
                await audioService.playChunk(const Duration(seconds: 30));
              }
            } else if (state is EmojiGameLoading) {
              await audioService.pause();
            }

            if (state is EmojiGameStageCompleted) {
              context.pushReplacementNamed(
                RouteNames.emojiStageResult,
                extra: state.completedStage,
              );
            } else if (state is EmojiGameAllStagesCompleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.emojiAllStagesCompleted),
                  backgroundColor: Colors.amber,
                ),
              );
              context.pop();
            } else if (state is EmojiGameError) {
              final message = state.message == 'notEnoughCoins'
                  ? context.l10n.notEnoughCoins
                  : state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: context.colors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is EmojiGameLoading || state is EmojiGameInitial) {
              return const Center(child: LogoLoader(size: 100));
            }

            if (state is EmojiGameReady) {
              return _buildGameUI(context, state);
            }

            if (state is EmojiGameCorrect) {
              return _buildSuccessUI(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGameUI(BuildContext context, EmojiGameReady state) {
    return FlashOverlayWidget(
      flashRed: _flashRed,
      flashGreen: _flashGreen,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TOP SECTION
                    Column(
                      children: [
                        const SizedBox(height: 16),
                        // Progress
                        Text(
                          context.l10n.stageAndQuestionProgress(
                            state.currentStage,
                            state.currentQuestionIndex + 1,
                          ),
                          style: context.typography.titleMedium?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    // MIDDLE SECTION (Emojis)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 48,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151219),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 24,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Builder(
                          builder: (context) {
                            if (state.question.visualMode ==
                                    'illustration_board' &&
                                state.question.visualScenes != null) {
                              final visibleScenes =
                                  state.question.visualScenes!;

                              Widget buildErrorPlaceholder(int level) {
                                return Container(
                                  color: Colors.white10,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        color: Colors.white30,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Sahne $level",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1,
                                    ),
                                itemCount: visibleScenes.length,
                                itemBuilder: (context, index) {
                                  final scene = visibleScenes[index];
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.asset(
                                              scene.assetPath,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) =>
                                                  Container(
                                                    width: 300,
                                                    height: 300,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF151219,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child:
                                                        buildErrorPlaceholder(
                                                          scene.hintLevel,
                                                        ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        scene.assetPath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            buildErrorPlaceholder(
                                              scene.hintLevel,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            if (state.question.imagePath != null) {
                              return state.question.imagePath!.endsWith('.svg')
                                  ? SvgPicture.asset(
                                      state.question.imagePath!,
                                      height: 80,
                                    )
                                  : Image.asset(
                                      state.question.imagePath!,
                                      height: 80,
                                    );
                            }

                            return Text(
                              state.question.emojis,
                              style: const TextStyle(
                                fontSize: 56,
                                letterSpacing: 4,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                    ),

                    // GAME UI LYRIC removed as per request
                    // BOTTOM SECTION
                    Column(
                      children: [
                        // Past guesses
                        if (state.pastGuesses.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: context.colors.error.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.colors.error.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              context.l10n.wrongGuessLabel(
                                state.pastGuesses.last,
                              ),
                              style: context.typography.bodyMedium?.copyWith(
                                color: context.colors.error,
                              ),
                            ),
                          ),

                        // Revealed Hints (if any)
                        if (state.hasRevealedArtist ||
                            state.revealedLetterIndices.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E28),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                if (state.hasRevealedArtist)
                                  Text(
                                    context.l10n.artistLabel(
                                      state.question.artist,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (state.revealedLetterIndices.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _getMaskedTitle(
                                        state.question.answer,
                                        state.revealedLetterIndices,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        // Input + Hint + Play button
                        Row(
                          children: [
                            Expanded(
                              child: ShakeWidget(
                                shouldShake: _shakeInput,
                                child: GuessInputField(
                                  showFooter: false,
                                  showReplayButton: false,
                                  onSubmit: (guess) {
                                    context.read<EmojiGameBloc>().add(
                                      EmojiGuessSubmitted(guess),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Play button removed as per request                          const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E28),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.amber,
                                ),
                                onPressed: () => _showHintPopup(context, state),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMaskedTitle(String answer, List<int> revealedIndices) {
    String masked = '';
    for (int i = 0; i < answer.length; i++) {
      if (answer[i] == ' ') {
        masked += '   ';
      } else if (revealedIndices.contains(i)) {
        masked += answer[i];
      } else {
        masked += '_ ';
      }
    }
    return masked;
  }

  void _showHintPopup(BuildContext context, EmojiGameReady state) {
    showDialog(
      context: context,
      builder: (dContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF151219).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.15),
                blurRadius: 32,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.jokersTitle,
                style: context.typography.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildJokerButton(
                context,
                icon: Icons.abc_rounded,
                title: context.l10n.revealLetter,
                price: 10,
                onTap: () {
                  context.read<EmojiGameBloc>().add(
                    EmojiBuyLetterHintRequested(),
                  );
                  Navigator.pop(dContext);
                },
              ),
              const SizedBox(height: 12),
              if (!state.hasRevealedArtist) ...[
                _buildJokerButton(
                  context,
                  icon: Icons.person_search_rounded,
                  title: context.l10n.revealArtist,
                  price: 20,
                  onTap: () {
                    context.read<EmojiGameBloc>().add(
                      EmojiBuyArtistHintRequested(),
                    );
                    Navigator.pop(dContext);
                  },
                ),
                const SizedBox(height: 12),
              ],
              _buildJokerButton(
                context,
                icon: Icons.skip_next_rounded,
                title: context.l10n.giveUpAndSkip,
                price: 20,
                isDangerous: true,
                onTap: () {
                  context.read<EmojiGameBloc>().add(EmojiGiveUpRequested());
                  Navigator.pop(dContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJokerButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int price,
    required VoidCallback onTap,
    bool isDangerous = false,
  }) {
    final color = isDangerous ? context.colors.error : context.colors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: context.typography.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$price',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessUI(BuildContext context, EmojiGameCorrect state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      // Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (state.isSkipped
                                      ? const Color(0xFFFFA500)
                                      : const Color(0xFF1ED760))
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                (state.isSkipped
                                        ? const Color(0xFFFFA500)
                                        : const Color(0xFF1ED760))
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isSkipped
                                  ? Icons.skip_next_rounded
                                  : Icons.star_rounded,
                              color: state.isSkipped
                                  ? const Color(0xFFFFA500)
                                  : const Color(0xFF1ED760),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              state.isSkipped ? 'PAS GEÇİLDİ' : 'DOĞRU CEVAP!',
                              style: context.typography.labelLarge?.copyWith(
                                color: state.isSkipped
                                    ? const Color(0xFFFFA500)
                                    : const Color(0xFF1ED760),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Content Area
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E28),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: [
                            // Top Row: Emojis and Album Art
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Emojis (Smaller)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Center(
                                      child: state.question.imagePath != null
                                          ? (state.question.imagePath!.endsWith(
                                                  '.svg',
                                                )
                                                ? SvgPicture.asset(
                                                    state.question.imagePath!,
                                                    height: 48,
                                                  )
                                                : Image.asset(
                                                    state.question.imagePath!,
                                                    height: 48,
                                                  ))
                                          : Text(
                                              state.question.emojis,
                                              style: const TextStyle(
                                                fontSize: 36,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Album Art CD
                                if (state.track != null)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          state.track!.albumArtUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: context.colors.surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.music_note,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Track Info
                            Text(
                              state.question.answer,
                              style: context.typography.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.question.artist,
                              style: context.typography.titleMedium?.copyWith(
                                color: Colors.white54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Lyric Reveal removed as per request
                            const SizedBox(height: 24),

                            // Audio controls removed as per request
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),

                      // Feedback Section
                      Text(
                        "Bu bulmaca nasıldı?",
                        style: context.typography.labelLarge?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeedbackButton(
                            context,
                            "💡 Zekice",
                            Colors.amber,
                          ),
                          _buildFeedbackButton(
                            context,
                            "🟢 Kolaydı",
                            Colors.green,
                          ),
                          _buildFeedbackButton(
                            context,
                            "🤠 Zordu",
                            Colors.orange,
                          ),
                          _buildFeedbackButton(
                            context,
                            "❓ Anlamsız",
                            Colors.redAccent,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Next Button
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<EmojiGameBloc>().add(
                            EmojiNextQuestionRequested(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF4A90E2,
                          ), // Bright Blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sıradaki Şarkı",
                              style: context.typography.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackButton(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: context.typography.labelSmall?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
