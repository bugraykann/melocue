import 'package:equatable/equatable.dart';
import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/features/game/domain/entities/leaderboard_entry.dart';

abstract class RanksState extends Equatable {
  const RanksState();
  
  @override
  List<Object> get props => [];
}

class RanksLoading extends RanksState {}

class RanksLoaded extends RanksState {
  final List<LeaderboardEntry> entries;
  final String currentFilter; // 'Global', 'Friends', 'US'
  final LeaderboardEntry? currentUserEntry;
  final int currentUserRank;

  const RanksLoaded({
    required this.entries,
    required this.currentFilter,
    this.currentUserEntry,
    required this.currentUserRank,
  });

  @override
  List<Object> get props => [
        entries,
        currentFilter,
        currentUserEntry ?? false,
        currentUserRank,
      ];
}

class RanksError extends RanksState {
  final Failure failure;

  const RanksError(this.failure);

  @override
  List<Object> get props => [failure];
}
