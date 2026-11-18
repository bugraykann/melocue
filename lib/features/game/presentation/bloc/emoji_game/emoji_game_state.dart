import 'package:equatable/equatable.dart';
import 'package:melocue/features/game/data/models/emoji_levels_data.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';

sealed class EmojiGameState extends Equatable {
  const EmojiGameState();

  @override
  List<Object?> get props => [];
}

class EmojiGameInitial extends EmojiGameState {}

class EmojiGameLoading extends EmojiGameState {}

class EmojiGameReady extends EmojiGameState {
  final int currentStage;
  final int currentQuestionIndex;
  final EmojiQuestion question;
  final List<String> pastGuesses;
  final List<int> revealedLetterIndices;
  final bool hasRevealedArtist;

  const EmojiGameReady({
    required this.currentStage,
    required this.currentQuestionIndex,
    required this.question,
    this.pastGuesses = const [],
    this.revealedLetterIndices = const [],
    this.hasRevealedArtist = false,
  });

  EmojiGameReady copyWith({
    int? currentStage,
    int? currentQuestionIndex,
    EmojiQuestion? question,
    List<String>? pastGuesses,
    List<int>? revealedLetterIndices,
    bool? hasRevealedArtist,
  }) {
    return EmojiGameReady(
      currentStage: currentStage ?? this.currentStage,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      question: question ?? this.question,
      pastGuesses: pastGuesses ?? this.pastGuesses,
      revealedLetterIndices: revealedLetterIndices ?? this.revealedLetterIndices,
      hasRevealedArtist: hasRevealedArtist ?? this.hasRevealedArtist,
    );
  }

  @override
  List<Object?> get props => [
        currentStage,
        currentQuestionIndex,
        question,
        pastGuesses,
        revealedLetterIndices,
        hasRevealedArtist,
      ];
}

class EmojiGameCorrect extends EmojiGameState {
  final int currentStage;
  final EmojiQuestion question;
  final TrackEntity? track;
  final bool isSkipped;

  const EmojiGameCorrect({
    required this.currentStage,
    required this.question,
    this.track,
    this.isSkipped = false,
  });

  @override
  List<Object?> get props => [currentStage, question, track, isSkipped];
}

class EmojiGameStageCompleted extends EmojiGameState {
  final int completedStage;
  const EmojiGameStageCompleted(this.completedStage);

  @override
  List<Object?> get props => [completedStage];
}

class EmojiGameAllStagesCompleted extends EmojiGameState {}

class EmojiGameError extends EmojiGameState {
  final String message;
  const EmojiGameError(this.message);

  @override
  List<Object?> get props => [message];
}
