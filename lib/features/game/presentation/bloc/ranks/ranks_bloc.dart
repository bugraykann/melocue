import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:melocue/features/game/domain/entities/leaderboard_entry.dart';
import 'package:melocue/features/game/domain/repositories/leaderboard_repository.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_event.dart';
import 'package:melocue/features/game/presentation/bloc/ranks/ranks_state.dart';

class RanksBloc extends Bloc<RanksEvent, RanksState> {
  final LeaderboardRepository leaderboardRepository;
  StreamSubscription? _leaderboardSubscription;

  RanksBloc({required this.leaderboardRepository}) : super(RanksLoading()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<UpdateScoreRequested>(_onUpdateScoreRequested);
    on<_LeaderboardUpdated>((event, emit) {
      emit(
        RanksLoaded(
          entries: event.entries,
          currentFilter: event.filter,
          currentUserEntry: event.currentUserEntry,
          currentUserRank: event.currentUserRank,
        ),
      );
    });
    on<_LeaderboardFailed>((event, emit) {
      emit(RanksError(event.failure));
    });
  }

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<RanksState> emit,
  ) async {
    emit(RanksLoading());
    await _leaderboardSubscription?.cancel();

    _leaderboardSubscription = leaderboardRepository
        .watchLeaderboard(event.filter)
        .listen((result) {
          result.fold(
            (entries) {
              final currentUser = FirebaseAuth.instance.currentUser;
              final currentUid = currentUser?.uid;

              int rank = -1;
              for (int i = 0; i < entries.length; i++) {
                if (entries[i].uid == currentUid) {
                  rank = i + 1;
                  break;
                }
              }

              final currentUserEntry = rank != -1 ? entries[rank - 1] : null;

              if (!isClosed) {
                // Emitting state asynchronously from stream listener
                add(
                  _LeaderboardUpdated(
                    entries: entries,
                    filter: event.filter,
                    currentUserEntry: currentUserEntry,
                    currentUserRank: rank,
                  ),
                );
              }
            },
            (failure) {
              if (!isClosed) {
                add(_LeaderboardFailed(failure));
              }
            },
          );
        });
  }

  Future<void> _onUpdateScoreRequested(
    UpdateScoreRequested event,
    Emitter<RanksState> emit,
  ) async {
    await leaderboardRepository.submitScore(
      points: event.points,
      avgTime: event.avgTime,
      streak: event.streak,
    );
  }

  @override
  Future<void> close() {
    _leaderboardSubscription?.cancel();
    return super.close();
  }
}

// Internal events for stream updates
class _LeaderboardUpdated extends RanksEvent {
  final List<LeaderboardEntry> entries;
  final String filter;
  final LeaderboardEntry? currentUserEntry;
  final int currentUserRank;

  const _LeaderboardUpdated({
    required this.entries,
    required this.filter,
    this.currentUserEntry,
    required this.currentUserRank,
  });
}

class _LeaderboardFailed extends RanksEvent {
  final dynamic failure;
  const _LeaderboardFailed(this.failure);
}
