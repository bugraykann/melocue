import 'package:equatable/equatable.dart';

sealed class EmojiGameEvent extends Equatable {
  const EmojiGameEvent();

  @override
  List<Object?> get props => [];
}

class EmojiGameStarted extends EmojiGameEvent {}

class EmojiGuessSubmitted extends EmojiGameEvent {
  final String guess;
  const EmojiGuessSubmitted(this.guess);

  @override
  List<Object?> get props => [guess];
}

class EmojiBuyLetterHintRequested extends EmojiGameEvent {}

class EmojiBuyArtistHintRequested extends EmojiGameEvent {}

class EmojiGiveUpRequested extends EmojiGameEvent {}

class EmojiNextQuestionRequested extends EmojiGameEvent {}
