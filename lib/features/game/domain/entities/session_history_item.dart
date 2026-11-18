import 'package:equatable/equatable.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';

class SessionHistoryItem extends Equatable {
  final TrackEntity track;
  final bool isVictory;
  final bool isSkip;
  final int finalChunkIndex;
  final Duration finalDuration;

  const SessionHistoryItem({
    required this.track,
    required this.isVictory,
    required this.isSkip,
    required this.finalChunkIndex,
    required this.finalDuration,
  });

  @override
  List<Object?> get props => [
        track,
        isVictory,
        isSkip,
        finalChunkIndex,
        finalDuration,
      ];
}
