import 'package:equatable/equatable.dart';
import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/domain/entities/session_history_item.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameReviveOffer extends GameState {
  final GameReady previousState;

  const GameReviveOffer(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class GameReady extends GameState {
  final TrackEntity currentTrack;
  final List<Duration> chunks;
  final int currentChunkIndex; // 0 to chunks.length - 1
  final bool isPlaying;
  final List<String> pastGuesses; // to track what user guessed so far
  final List<SessionHistoryItem> sessionHistory; // track previously played songs in this session
  final Set<int> revealedHintIndices; // indices of track name characters revealed as hints
  final bool hasRevealedArtist; // true if user bought the Artist hint
  final int streak; // track consecutive wins
  final bool hasPlayedCurrentChunk;
  final GameMode mode;
  final String? modeParameter;
  
  const GameReady({
    required this.currentTrack,
    required this.chunks,
    required this.currentChunkIndex,
    required this.mode,
    this.modeParameter,
    this.isPlaying = false,
    this.hasPlayedCurrentChunk = false,
    this.pastGuesses = const [],
    this.sessionHistory = const [],
    this.revealedHintIndices = const {},
    this.hasRevealedArtist = false,
    this.streak = 0,
  });

  Duration get currentChunkDuration => chunks[currentChunkIndex];

  GameReady copyWith({
    TrackEntity? currentTrack,
    List<Duration>? chunks,
    int? currentChunkIndex,
    bool? isPlaying,
    bool? hasPlayedCurrentChunk,
    List<String>? pastGuesses,
    List<SessionHistoryItem>? sessionHistory,
    Set<int>? revealedHintIndices,
    bool? hasRevealedArtist,
    int? streak,
    GameMode? mode,
    String? modeParameter,
  }) {
    return GameReady(
      currentTrack: currentTrack ?? this.currentTrack,
      chunks: chunks ?? this.chunks,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      mode: mode ?? this.mode,
      modeParameter: modeParameter ?? this.modeParameter,
      isPlaying: isPlaying ?? this.isPlaying,
      hasPlayedCurrentChunk: hasPlayedCurrentChunk ?? this.hasPlayedCurrentChunk,
      pastGuesses: pastGuesses ?? this.pastGuesses,
      sessionHistory: sessionHistory ?? this.sessionHistory,
      revealedHintIndices: revealedHintIndices ?? this.revealedHintIndices,
      hasRevealedArtist: hasRevealedArtist ?? this.hasRevealedArtist,
      streak: streak ?? this.streak,
    );
  }

  @override
  List<Object?> get props => [
        currentTrack,
        chunks,
        currentChunkIndex,
        isPlaying,
        hasPlayedCurrentChunk,
        pastGuesses,
        sessionHistory,
        revealedHintIndices,
        hasRevealedArtist,
        streak,
        mode,
        modeParameter,
      ];
}

class GameError extends GameState {
  final Failure failure;

  const GameError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class GameOver extends GameState {
  final List<SessionHistoryItem> sessionHistory;
  final GameMode mode;
  final String? modeParameter;

  const GameOver({
    required this.sessionHistory, 
    required this.mode,
    this.modeParameter,
  });

  @override
  List<Object?> get props => [
        sessionHistory,
        mode,
        modeParameter,
      ];
}
