import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/core/utils/result.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/domain/entities/session_history_item.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';
import 'package:melocue/features/game/domain/repositories/game_repository.dart';
import 'package:melocue/features/game/domain/repositories/leaderboard_repository.dart';
import 'package:melocue/features/game/domain/services/audio_player_service.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:melocue/features/game/presentation/bloc/game_state.dart';
import 'package:melocue/core/network/spotify_api_service.dart';
import 'package:dio/dio.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository gameRepository;
  final LeaderboardRepository leaderboardRepository;
  final AudioPlayerService audioPlayerService;
  final LocalStorageService localStorageService;
  StreamSubscription? _playerStateSubscription;

  // Track queue for minimizing API calls
  final List<TrackEntity> _upcomingTracks = [];

  // The duration chunks for progressive listening
  static const List<Duration> defaultChunks = [
    Duration(milliseconds: 500), // 0.5s
    Duration(milliseconds: 1500), // 1.5s
    Duration(seconds: 5), // 5.0s
    Duration(seconds: 10), // 10.0s
    Duration(seconds: 20), // 20.0s
    Duration(seconds: 30), // 30.0s
  ];

  GameBloc({
    required this.gameRepository,
    required this.leaderboardRepository,
    required this.audioPlayerService,
    required this.localStorageService,
  }) : super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<PlayChunkRequested>(_onPlayChunkRequested);
    on<ReplayChunkRequested>(_onReplayChunkRequested);
    on<PlaybackCompleted>(_onPlaybackCompleted);
    on<PauseRequested>(_onPauseRequested);
    on<GuessSubmitted>(_onGuessSubmitted);
    on<GiveUpRequested>(_onGiveUpRequested);
    on<BuyLetterHintRequested>(_onBuyLetterHintRequested);
    on<BuyArtistHintRequested>(_onBuyArtistHintRequested);
    on<SkipTrackRequested>(_onSkipTrackRequested);
    on<ReviveAccepted>(_onReviveAccepted);
    on<ReviveDeclined>(_onReviveDeclined);

    // Listen to player state to sync isPlaying with UI
    _playerStateSubscription = audioPlayerService.playerStateStream.listen((
      playerState,
    ) {
      if (state is GameReady) {
        final st = state as GameReady;
        // If it was playing but it stopped (because clip ended)
        if (st.isPlaying && !playerState.playing) {
          // We could emit a state update here, but we can't emit from outside an event handler safely in bloc >= 8.0 without adding an event.
          // However, just_audio state stream might be overkill if we just rely on playChunk's future.
          // We will handle it by awaiting playChunk in the event.
        }
      }
    });
  }

  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    // Clear queue when explicitly starting a new game session
    _upcomingTracks.clear();

    await _fetchAndEmitReadyState(
      emit,
      mode: event.mode,
      modeParameter: event.modeParameter,
      sessionHistory: const [],
      streak: localStorageService.currentStreak,
    );
  }

  Future<void> _fetchAndEmitReadyState(
    Emitter<GameState> emit, {
    required GameMode mode,
    String? modeParameter,
    required List<SessionHistoryItem> sessionHistory,
    required int streak,
  }) async {
    final isDaily = mode == GameMode.daily;

    if (_upcomingTracks.isEmpty) {
      Result<List<TrackEntity>, Failure> result;
      if (mode == GameMode.category && modeParameter != null) {
        result = await gameRepository.fetchTracksByCategory(modeParameter);
      } else if (mode == GameMode.fanTest && modeParameter != null) {
        result = await gameRepository.fetchTracksByArtist(modeParameter);
      } else if (mode == GameMode.myPlaylist && modeParameter != null) {
        final spotifyService = SpotifyApiService(Dio(), localStorageService);
        try {
          final trackNames = await spotifyService.getPlaylistTrackNames(modeParameter);
          
          if (trackNames.isEmpty) {
            result = const Error(UnknownFailure('Çalma listesinde şarkı bulunamadı.'));
          } else {
            trackNames.shuffle();
            final selectedNames = trackNames.take(15).toList(); // Fetch 15 to ensure we get at least 10 valid ones
            
            List<TrackEntity> tracks = [];
            for (var name in selectedNames) {
               final searchResult = await gameRepository.searchTracks(name);
               searchResult.fold((foundTracks) {
                 if (foundTracks.isNotEmpty) tracks.add(foundTracks.first);
               }, (f) => null);
               if (tracks.length >= 10) break;
            }
            
            if (tracks.isNotEmpty) {
               result = Success(tracks);
            } else {
               result = const Error(UnknownFailure('Listeden iTunes üzerinde çalınabilir uygun şarkı bulunamadı.'));
            }
          }
        } catch (e) {
          result = Error(UnknownFailure(e.toString().replaceAll('Exception: ', '')));
        }
      } else {
        result = await gameRepository.fetchTracks(isDaily: isDaily);
      }

      await result.fold(
        (tracks) async {
          _upcomingTracks.addAll(tracks);
        },
        (failure) async {
          emit(GameError(failure));
          return; // Early return on error
        },
      );
    }

    if (_upcomingTracks.isEmpty) {
      if (state is! GameError) {
        // Check to prevent overriding network errors
        emit(const GameError(UnknownFailure('No tracks found')));
      }
      return;
    }

    final currentTrack = _upcomingTracks.removeAt(0);

    try {
      await audioPlayerService.load(currentTrack.previewUrl);

      emit(
        GameReady(
          currentTrack: currentTrack,
          chunks: defaultChunks,
          currentChunkIndex: 0,
          mode: mode,
          modeParameter: modeParameter,
          isPlaying: false,
          streak: streak,
          sessionHistory: sessionHistory,
          revealedHintIndices: const {},
        ),
      );
    } catch (e) {
      emit(GameInitial());
    }
  }

  int _getModeLimit(GameMode mode) {
    switch (mode) {
      case GameMode.daily:
        return 1;
      case GameMode.fanTest:
      case GameMode.category:
      case GameMode.myPlaylist:
        return 10;
      case GameMode.endless:
        return -1; // No limit
    }
  }

  Future<void> _onPlayChunkRequested(
    PlayChunkRequested event,
    Emitter<GameState> emit,
  ) async {
    final st = state;
    if (st is! GameReady) return;
    if (st.isPlaying) return; // Prevent multiple plays overlapping

    GameReady nextState = st;

    if (st.hasPlayedCurrentChunk) {
      if (st.currentChunkIndex < st.chunks.length - 1) {
        final pastGuesses = List<String>.from(st.pastGuesses)..add('');

        // Reveal hints
        final int nextChunkIndex = st.currentChunkIndex + 1;
        // Only reveal 1 letter every 2 chunks (odd indices)
        int lettersToReveal = (nextChunkIndex % 2 != 0) ? 1 : 0;

        final updatedRevealed = Set<int>.from(st.revealedHintIndices);

        if (lettersToReveal > 0) {
          final unrevealed = <int>[];
          for (int i = 0; i < st.currentTrack.trackName.length; i++) {
            if (st.currentTrack.trackName[i] != ' ' &&
                !st.revealedHintIndices.contains(i)) {
              unrevealed.add(i);
            }
          }
          unrevealed.shuffle();
          updatedRevealed.addAll(unrevealed.take(lettersToReveal));
        }

        nextState = st.copyWith(
          currentChunkIndex: st.currentChunkIndex + 1,
          pastGuesses: pastGuesses,
          hasPlayedCurrentChunk: false,
          revealedHintIndices: updatedRevealed,
        );
      }
    }

    emit(nextState.copyWith(isPlaying: true, hasPlayedCurrentChunk: true));

    audioPlayerService
        .playChunk(nextState.chunks[nextState.currentChunkIndex])
        .whenComplete(() {
          if (!isClosed) {
            add(PlaybackCompleted());
          }
        });
  }

  Future<void> _onReplayChunkRequested(
    ReplayChunkRequested event,
    Emitter<GameState> emit,
  ) async {
    final st = state;
    if (st is! GameReady) return;
    if (st.isPlaying) return;

    emit(st.copyWith(isPlaying: true));

    audioPlayerService.playChunk(st.chunks[st.currentChunkIndex]).whenComplete(
      () {
        if (!isClosed) {
          add(PlaybackCompleted());
        }
      },
    );
  }

  void _onPlaybackCompleted(PlaybackCompleted event, Emitter<GameState> emit) {
    if (state is GameReady) {
      emit((state as GameReady).copyWith(isPlaying: false));
    }
  }

  Future<void> _onPauseRequested(
    PauseRequested event,
    Emitter<GameState> emit,
  ) async {
    await audioPlayerService.pause();
    if (state is GameReady) {
      emit((state as GameReady).copyWith(isPlaying: false));
    }
  }

  Future<void> _onGuessSubmitted(
    GuessSubmitted event,
    Emitter<GameState> emit,
  ) async {
    final st = state;
    if (st is! GameReady) return;

    final guess = event.guess.trim().toLowerCase();
    bool isCorrect = false;
    if (guess.isNotEmpty) {
      final expectedTrack = st.currentTrack.trackName.toLowerCase();
      final expectedArtist = st.currentTrack.artistName.toLowerCase();

      isCorrect =
          guess == expectedTrack ||
          guess == '$expectedArtist - $expectedTrack' ||
          guess == '$expectedArtist • $expectedTrack' ||
          guess.contains(expectedTrack) ||
          (expectedTrack.contains(guess) &&
              guess.length >= 3 &&
              guess.length >= expectedTrack.length * 0.5);
    }

    if (isCorrect) {
      await audioPlayerService.pause();

      final newStreak = st.streak + 1;
      
      // Calculate points based on how early the user guessed
      int pointsEarned = 0;
      switch (st.currentChunkIndex) {
        case 0: pointsEarned = 100; break;
        case 1: pointsEarned = 80; break;
        case 2: pointsEarned = 60; break;
        case 3: pointsEarned = 40; break;
        case 4: pointsEarned = 20; break;
        default: pointsEarned = 10; break;
      }
      
      // Calculate avg time (simply based on current chunk duration)
      double currentAvg = st.chunks[st.currentChunkIndex].inMilliseconds / 1000.0;

      // Submit score to leaderboard
      await leaderboardRepository.submitScore(
        points: pointsEarned,
        avgTime: currentAvg,
        streak: newStreak,
      );

      // Track dynamic stats
      await localStorageService.incrementGamesPlayed();
      await localStorageService.incrementGamesWon();
      await localStorageService.saveStreak(newStreak);
      await localStorageService.incrementGuessCount(st.currentChunkIndex);
      
      if (st.currentTrack.genre != null && st.currentTrack.genre!.isNotEmpty) {
        await localStorageService.incrementGenreCount(st.currentTrack.genre!);
      }

      await localStorageService.saveLastSolvedTrack(
        st.currentTrack.trackName,
        st.currentTrack.artistName,
        st.currentTrack.albumArtUrl,
      );

      final historyItem = SessionHistoryItem(
        track: st.currentTrack,
        isVictory: true,
        isSkip: false,
        finalChunkIndex: st.currentChunkIndex,
        finalDuration: st.chunks[st.currentChunkIndex],
      );
      final updatedHistory = List<SessionHistoryItem>.from(st.sessionHistory)
        ..insert(0, historyItem);

      final limit = _getModeLimit(st.mode);
      if (limit > 0 && updatedHistory.length >= limit) {
        await _saveSessionStats(st.mode, st.modeParameter, updatedHistory);
        emit(
          GameOver(
            sessionHistory: updatedHistory,
            mode: st.mode,
            modeParameter: st.modeParameter,
          ),
        );
      } else {
        if (st.mode == GameMode.endless) {
          await _saveSingleTrackStat(
            st.mode,
            st.modeParameter,
            true,
            newStreak,
          );
        }
        emit(GameLoading());
        await _fetchAndEmitReadyState(
          emit,
          mode: st.mode,
          modeParameter: st.modeParameter,
          sessionHistory: updatedHistory,
          streak: newStreak,
        );
      }
    } else {
      // Incorrect guess acts like a skip
      final pastGuesses = List<String>.from(st.pastGuesses)..add(event.guess);

      // Reveal hints
      final int nextChunkIndex = st.currentChunkIndex + 1;
      // Only reveal 1 letter every 2 chunks (odd indices)
      int lettersToReveal = (nextChunkIndex % 2 != 0) ? 1 : 0;

      final updatedRevealed = Set<int>.from(st.revealedHintIndices);

      if (lettersToReveal > 0) {
        final unrevealed = <int>[];
        for (int i = 0; i < st.currentTrack.trackName.length; i++) {
          if (st.currentTrack.trackName[i] != ' ' &&
              !st.revealedHintIndices.contains(i)) {
            unrevealed.add(i);
          }
        }
        unrevealed.shuffle();
        updatedRevealed.addAll(unrevealed.take(lettersToReveal));
      }

      if (st.currentChunkIndex < st.chunks.length - 1) {
        emit(
          st.copyWith(
            currentChunkIndex: st.currentChunkIndex + 1,
            hasPlayedCurrentChunk: false,
            pastGuesses: pastGuesses,
            revealedHintIndices: updatedRevealed,
            // DO NOT CHANGE isPlaying: Let the background player finish the chunk!
          ),
        );
      } else {
        await audioPlayerService.pause();

        if (st.mode == GameMode.endless) {
          emit(GameReviveOffer(st));
          return;
        }

        await _handleDefeat(st, emit);
      }
    }
  }

  Future<void> _onGiveUpRequested(
    GiveUpRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameReady) return;
    final st = state as GameReady;

    await audioPlayerService.pause();

    // Track defeat stats
    await localStorageService.incrementGamesPlayed();
    await localStorageService.saveStreak(0);
    await localStorageService.incrementGuessCount(5); // 5 represents fail

    final historyItem = SessionHistoryItem(
      track: st.currentTrack,
      isVictory: false,
      isSkip: true,
      finalChunkIndex: st.currentChunkIndex,
      finalDuration: st.chunks[st.currentChunkIndex],
    );
    final updatedHistory = List<SessionHistoryItem>.from(st.sessionHistory)
      ..insert(0, historyItem);

    final limit = _getModeLimit(st.mode);
    if (limit > 0 && updatedHistory.length >= limit) {
      await _saveSessionStats(st.mode, st.modeParameter, updatedHistory);
      emit(
        GameOver(
          sessionHistory: updatedHistory,
          mode: st.mode,
          modeParameter: st.modeParameter,
        ),
      );
    } else {
      if (st.mode == GameMode.endless) {
        await _saveSingleTrackStat(st.mode, st.modeParameter, false, 0);
      }
      emit(GameLoading());
      await _fetchAndEmitReadyState(
        emit,
        mode: st.mode,
        modeParameter: st.modeParameter,
        sessionHistory: updatedHistory,
        streak: 0,
      );
    }
  }

  Future<void> _saveSessionStats(
    GameMode mode,
    String? modeParameter,
    List<SessionHistoryItem> history,
  ) async {
    final playedCount = history.length;
    final wonCount = history.where((i) => i.isVictory).length;

    for (int i = 0; i < playedCount; i++) {
      await localStorageService.incrementGamesPlayed();
    }
    for (int i = 0; i < wonCount; i++) {
      await localStorageService.incrementGamesWon();
    }

    if (mode == GameMode.daily) {
      await localStorageService.markDailyPlayedToday();
    } else if (mode == GameMode.category && modeParameter != null) {
      for (int i = 0; i < playedCount; i++) {
        await localStorageService.incrementCategoryPlayed(modeParameter);
      }
      for (int i = 0; i < wonCount; i++) {
        await localStorageService.incrementCategoryWon(modeParameter);
      }
    } else if (mode == GameMode.fanTest && modeParameter != null) {
      await localStorageService.saveFanTestHighScore(modeParameter, wonCount);
    }
  }

  Future<void> _saveSingleTrackStat(
    GameMode mode,
    String? modeParameter,
    bool isVictory,
    int streak,
  ) async {
    await localStorageService.saveStreak(streak);
    await localStorageService.incrementGamesPlayed();
    if (isVictory) {
      await localStorageService.incrementGamesWon();
    }

    if (mode == GameMode.daily) {
      await localStorageService.markDailyPlayedToday();
    } else if (mode == GameMode.category && modeParameter != null) {
      await localStorageService.incrementCategoryPlayed(modeParameter);
      if (isVictory) {
        await localStorageService.incrementCategoryWon(modeParameter);
      }
    }
  }

  // --- Monetization & Hints Handlers --- //

  Future<void> _onBuyLetterHintRequested(BuyLetterHintRequested event, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final st = state as GameReady;
    
    final success = await localStorageService.deductCoins(10);
    if (!success) return;

    final unrevealed = <int>[];
    for (int i = 0; i < st.currentTrack.trackName.length; i++) {
      if (st.currentTrack.trackName[i] != ' ' && !st.revealedHintIndices.contains(i)) {
        unrevealed.add(i);
      }
    }
    if (unrevealed.isEmpty) return; 
    
    unrevealed.shuffle();
    final updatedRevealed = Set<int>.from(st.revealedHintIndices)..add(unrevealed.first);
    emit(st.copyWith(revealedHintIndices: updatedRevealed));
  }

  Future<void> _onBuyArtistHintRequested(BuyArtistHintRequested event, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final st = state as GameReady;
    if (st.hasRevealedArtist) return;

    final success = await localStorageService.deductCoins(20);
    if (!success) return;

    emit(st.copyWith(hasRevealedArtist: true));
  }

  Future<void> _onSkipTrackRequested(SkipTrackRequested event, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final st = state as GameReady;

    final success = await localStorageService.deductCoins(20);
    if (!success) return;

    await audioPlayerService.pause();
    
    // Skip adds to history as a "skip" item but preserves streak
    final historyItem = SessionHistoryItem(
      track: st.currentTrack,
      isVictory: false,
      isSkip: true,
      finalChunkIndex: st.currentChunkIndex,
      finalDuration: st.chunks[st.currentChunkIndex],
    );
    final updatedHistory = List<SessionHistoryItem>.from(st.sessionHistory)
      ..insert(0, historyItem);

    final limit = _getModeLimit(st.mode);
    if (limit > 0 && updatedHistory.length >= limit) {
      await _saveSessionStats(st.mode, st.modeParameter, updatedHistory);
      emit(
        GameOver(
          sessionHistory: updatedHistory,
          mode: st.mode,
          modeParameter: st.modeParameter,
        ),
      );
    } else {
      emit(GameLoading());
      await _fetchAndEmitReadyState(
        emit,
        mode: st.mode,
        modeParameter: st.modeParameter,
        sessionHistory: updatedHistory,
        streak: st.streak, // Streak is preserved!
      );
    }
  }

  Future<void> _handleDefeat(GameReady st, Emitter<GameState> emit) async {
    // Track defeat stats
    await localStorageService.incrementGamesPlayed();
    await localStorageService.saveStreak(0);
    await localStorageService.incrementGuessCount(5); // 5 represents fail

    final historyItem = SessionHistoryItem(
      track: st.currentTrack,
      isVictory: false,
      isSkip: true,
      finalChunkIndex: st.currentChunkIndex,
      finalDuration: st.chunks[st.currentChunkIndex],
    );
    final updatedHistory = List<SessionHistoryItem>.from(st.sessionHistory)
      ..insert(0, historyItem);

    final limit = _getModeLimit(st.mode);
    if (limit > 0 && updatedHistory.length >= limit) {
      await _saveSessionStats(st.mode, st.modeParameter, updatedHistory);
      emit(
        GameOver(
          sessionHistory: updatedHistory,
          mode: st.mode,
          modeParameter: st.modeParameter,
        ),
      );
    } else {
      if (st.mode == GameMode.endless) {
        await _saveSingleTrackStat(st.mode, st.modeParameter, false, 0);
      }
      emit(GameLoading());
      await _fetchAndEmitReadyState(
        emit,
        mode: st.mode,
        modeParameter: st.modeParameter,
        sessionHistory: updatedHistory,
        streak: 0,
      );
    }
  }

  Future<void> _onReviveAccepted(ReviveAccepted event, Emitter<GameState> emit) async {
    final st = event.previousState;
    // Remove the last incorrect guess from pastGuesses so they get one more try
    final pastGuesses = List<String>.from(st.pastGuesses);
    if (pastGuesses.isNotEmpty) {
      pastGuesses.removeLast();
    }
    
    // Give them another chance on the last chunk
    emit(st.copyWith(
      pastGuesses: pastGuesses,
      hasPlayedCurrentChunk: false,
    ));
  }

  Future<void> _onReviveDeclined(ReviveDeclined event, Emitter<GameState> emit) async {
    await _handleDefeat(event.previousState, emit);
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    audioPlayerService.dispose();
    return super.close();
  }
}
