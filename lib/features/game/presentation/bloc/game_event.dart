import 'package:equatable/equatable.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final GameMode mode;
  final String? modeParameter;

  const GameStarted({required this.mode, this.modeParameter});

  @override
  List<Object?> get props => [mode, modeParameter];
}

class PlayChunkRequested extends GameEvent {}

class ReplayChunkRequested extends GameEvent {}

class PauseRequested extends GameEvent {}

class GiveUpRequested extends GameEvent {}

class GuessSubmitted extends GameEvent {
  final String guess;

  const GuessSubmitted(this.guess);

  @override
  List<Object?> get props => [guess];
}

class NextTrackRequested extends GameEvent {}

class PlaybackStateChanged extends GameEvent {
  final bool isPlaying;

  const PlaybackStateChanged(this.isPlaying);

  @override
  List<Object> get props => [isPlaying];
}

// --- Monetization & Hints --- //

class BuyLetterHintRequested extends GameEvent {}

class BuyArtistHintRequested extends GameEvent {}

class SkipTrackRequested extends GameEvent {}

class ReviveAccepted extends GameEvent {
  final GameReady previousState;
  const ReviveAccepted(this.previousState);
  @override
  List<Object> get props => [previousState];
}

class ReviveDeclined extends GameEvent {
  final GameReady previousState;
  const ReviveDeclined(this.previousState);
  @override
  List<Object> get props => [previousState];
}

class SkipChunkRequested extends GameEvent {}

class PlaybackCompleted extends GameEvent {}
