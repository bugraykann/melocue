import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';
import 'package:melocue/features/game/domain/repositories/game_repository.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';

class GuessInputField extends StatefulWidget {
  final Function(String) onSubmit;
  final bool showFooter;
  final bool showReplayButton;

  const GuessInputField({
    super.key,
    required this.onSubmit,
    this.showFooter = true,
    this.showReplayButton = true,
  });

  @override
  State<GuessInputField> createState() => _GuessInputFieldState();
}

class _GuessInputFieldState extends State<GuessInputField> {
  String _currentQuery = '';
  List<TrackEntity> _options = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onQueryChanged(String query) async {
    HapticFeedback.selectionClick();
    _currentQuery = query;
    if (query.trim().length < 2) {
      if (mounted) {
        setState(() {
          _options = [];
        });
      }
      return;
    }

    // Brief delay to act as a pseudo-debouncer
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || _currentQuery != query) return; // Drop stale queries

    final result = await context.read<GameRepository>().searchTracks(query);
    if (!mounted || _currentQuery != query) return;

    result.fold(
      (tracks) {
        setState(() {
          _options = tracks.take(5).toList(); // Show top 5 suggestions
        });
      },
      (failure) {
        setState(() {
          _options = [];
        });
      },
    );
  }

  void _submit(String value) {
    widget.onSubmit(value);
    _controller.clear();
    _currentQuery = '';
    setState(() {
      _options = [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select((GameBloc bloc) {
      final state = bloc.state;
      return state is GameReady && state.isPlaying;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_options.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF2C2C35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _options.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFF3B3B44)),
              itemBuilder: (context, index) {
                final option = _options[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      option.albumArtUrl,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    option.trackName,
                    style: context.typography.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    option.artistName,
                    style: context.typography.bodySmall?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _submit('${option.artistName} - ${option.trackName}');
                  },
                );
              },
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B22),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              if (widget.showReplayButton) ...[
                4.w,
                IconButton(
                  onPressed: isPlaying
                      ? null
                      : () {
                          context.read<GameBloc>().add(ReplayChunkRequested());
                        },
                  icon: Icon(
                    Icons.replay_rounded,
                    color: isPlaying ? Colors.white24 : const Color(0xFFE0E0E0),
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints:
                      const BoxConstraints(), // reduces default padding
                ),
              ],
              4.w,
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  style: context.typography.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.guessInputPlaceholder,
                    hintStyle: context.typography.bodyLarge?.copyWith(
                      color: const Color(0xFF555555),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) {
                    _submit(val);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final isEmpty = value.text.trim().isEmpty;
                    return ElevatedButton.icon(
                      onPressed: () {
                        if (isEmpty) {
                          _submit(''); // empty guess means skip
                        } else {
                          _submit(value.text);
                        }
                      },
                      icon: Text(
                        isEmpty
                            ? context.l10n.skipAction
                            : context.l10n.submitButton,
                        style: TextStyle(
                          color: isEmpty ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Icon(
                        isEmpty ? Icons.redo_rounded : Icons.send_rounded,
                        color: isEmpty ? Colors.white : Colors.black,
                        size: 16,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEmpty
                            ? Colors.transparent
                            : const Color(0xFF1ED760),
                        elevation: isEmpty ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: isEmpty
                              ? const BorderSide(color: Colors.white24)
                              : BorderSide.none,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.showFooter) ...[
          16.h,
          // Footer Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFF08C36),
                    size: 16,
                  ),
                  6.w,
                  Text(
                    context.l10n.genreHintUnlockedAt,
                    style: context.typography.labelMedium?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    context.l10n.howToPlay,
                    style: context.typography.labelMedium?.copyWith(
                      color: const Color(0xFFB3B3B3),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFB3B3B3),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}
