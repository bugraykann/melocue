import 'package:equatable/equatable.dart';

abstract class RanksEvent extends Equatable {
  const RanksEvent();

  @override
  List<Object> get props => [];
}

class LoadLeaderboard extends RanksEvent {
  final String filter; // 'Global', 'Friends', 'US'

  const LoadLeaderboard({this.filter = 'Global'});

  @override
  List<Object> get props => [filter];
}

class UpdateScoreRequested extends RanksEvent {
  final int points;
  final double avgTime;
  final int streak;

  const UpdateScoreRequested({
    required this.points,
    required this.avgTime,
    required this.streak,
  });

  @override
  List<Object> get props => [points, avgTime, streak];
}
