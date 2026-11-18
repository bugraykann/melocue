import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/data/models/emoji_levels_data.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_event.dart';
import 'package:melocue/features/game/presentation/bloc/emoji_game/emoji_game_state.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';

import 'package:melocue/features/game/domain/repositories/game_repository.dart';

class EmojiGameBloc extends Bloc<EmojiGameEvent, EmojiGameState> {
  final LocalStorageService localStorageService;
  final GameRepository gameRepository;

  EmojiGameBloc({
    required this.localStorageService,
    required this.gameRepository,
  }) : super(EmojiGameInitial()) {
    on<EmojiGameStarted>(_onGameStarted);
    on<EmojiGuessSubmitted>(_onGuessSubmitted);
    on<EmojiBuyLetterHintRequested>(_onBuyLetterHintRequested);
    on<EmojiBuyArtistHintRequested>(_onBuyArtistHintRequested);
    on<EmojiGiveUpRequested>(_onGiveUpRequested);
    on<EmojiNextQuestionRequested>(_onNextQuestionRequested);
  }

  Future<void> _onGameStarted(EmojiGameStarted event, Emitter<EmojiGameState> emit) async {
    emit(EmojiGameLoading());
    await _loadCurrentQuestion(emit);
  }

  Future<void> _loadCurrentQuestion(Emitter<EmojiGameState> emit) async {
    final stageNumber = localStorageService.currentEmojiStage;
    final index = localStorageService.currentEmojiIndex;

    final countryCode = localStorageService.countryCode;
    final stages = await loadEmojiStagesData(countryCode);

    // Find stage data
    final stageData = stages.firstWhere(
      (s) => s.stageNumber == stageNumber,
      orElse: () => const EmojiStage(stageNumber: -1, questions: []),
    );

    if (stageData.stageNumber == -1) {
      if (stageNumber > 10) {
        emit(EmojiGameAllStagesCompleted());
      } else {
        emit(const EmojiGameError("Stage not found"));
      }
      return;
    }

    if (index >= stageData.questions.length) {
      // Stage completed! Move to next stage.
      final nextStage = stageNumber + 1;
      await localStorageService.saveCurrentEmojiStage(nextStage);
      await localStorageService.saveCurrentEmojiIndex(0);
      await localStorageService.unlockEmojiStage(nextStage); // Unlock it so they can select it
      
      emit(EmojiGameStageCompleted(stageNumber));
      return;
    }

    emit(EmojiGameReady(
      currentStage: stageNumber,
      currentQuestionIndex: index,
      question: stageData.questions[index],
    ));
  }

  Future<void> _onGuessSubmitted(EmojiGuessSubmitted event, Emitter<EmojiGameState> emit) async {
    if (state is! EmojiGameReady) return;
    final st = state as EmojiGameReady;

    final cleanedGuess = _cleanString(event.guess);
    final cleanedAnswer = _cleanString(st.question.answer);

    final isCorrect = cleanedGuess.contains(cleanedAnswer);
    final isSkip = cleanedGuess.isEmpty || cleanedGuess == 'pas' || cleanedGuess == 'pasgeç' || cleanedGuess == 'pasgec';

    if (isCorrect || isSkip) {
      // Fetch track from iTunes to show in success screen
      emit(EmojiGameLoading());
      
      final query = "${st.question.answer} ${st.question.artist}";
      final result = await gameRepository.searchTracks(query);
      
      TrackEntity? foundTrack;
      result.fold(
        (tracks) {
          if (tracks.isNotEmpty) {
            // Pick the first result that matches (or just the first result)
            foundTrack = tracks.first;
          }
        },
        (failure) {
          // Ignore failure, we just won't show album art or play preview
        },
      );
      
      emit(EmojiGameCorrect(
        currentStage: st.currentStage,
        question: st.question,
        track: foundTrack,
        isSkipped: isSkip,
      ));
    } else {
      // Incorrect
      final past = List<String>.from(st.pastGuesses)..add(event.guess);
      emit(st.copyWith(pastGuesses: past));
    }
  }

  Future<void> _onNextQuestionRequested(EmojiNextQuestionRequested event, Emitter<EmojiGameState> emit) async {
    if (state is! EmojiGameCorrect) return;
    
    // The current index is stored locally, we need to increment it.
    final currentIndex = localStorageService.currentEmojiIndex;
    final nextIndex = currentIndex + 1;
    await localStorageService.saveCurrentEmojiIndex(nextIndex);
    
    emit(EmojiGameLoading());
    await _loadCurrentQuestion(emit);
  }

  String _cleanString(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9ğüşöçığ]'), '').trim();
  }

  Future<void> _onBuyLetterHintRequested(EmojiBuyLetterHintRequested event, Emitter<EmojiGameState> emit) async {
    if (state is! EmojiGameReady) return;
    final st = state as EmojiGameReady;

    if (await localStorageService.deductCoins(10)) {
      final answer = st.question.answer;
      final unrevealed = <int>[];
      for (int i = 0; i < answer.length; i++) {
        if (answer[i].trim().isNotEmpty && !st.revealedLetterIndices.contains(i)) {
          unrevealed.add(i);
        }
      }

      if (unrevealed.isNotEmpty) {
        unrevealed.shuffle();
        final updated = List<int>.from(st.revealedLetterIndices)..add(unrevealed.first);
        emit(st.copyWith(revealedLetterIndices: updated));
      }
    } else {
      emit(const EmojiGameError("notEnoughCoins"));
      emit(st);
    }
  }

  Future<void> _onBuyArtistHintRequested(EmojiBuyArtistHintRequested event, Emitter<EmojiGameState> emit) async {
    if (state is! EmojiGameReady) return;
    final st = state as EmojiGameReady;

    if (st.hasRevealedArtist) return;

    if (await localStorageService.deductCoins(20)) {
      emit(st.copyWith(hasRevealedArtist: true));
    } else {
      emit(const EmojiGameError("notEnoughCoins"));
      emit(st);
    }
  }

  Future<void> _onGiveUpRequested(EmojiGiveUpRequested event, Emitter<EmojiGameState> emit) async {
    if (state is! EmojiGameReady) return;
    final st = state as EmojiGameReady;

    // User gave up, maybe they paid coins to skip?
    // For now, let's just let them skip for 20 coins
    if (await localStorageService.deductCoins(20)) {
      final nextIndex = st.currentQuestionIndex + 1;
      await localStorageService.saveCurrentEmojiIndex(nextIndex);
      emit(EmojiGameLoading());
      await _loadCurrentQuestion(emit);
    } else {
      emit(const EmojiGameError("notEnoughCoins"));
      emit(st);
    }
  }
}
