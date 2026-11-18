import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/core/utils/result.dart';
import 'package:melocue/features/game/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  /// Fetches a real-time stream of the leaderboard.
  /// [filter] could be 'global', 'friends', 'us', etc.
  Stream<Result<List<LeaderboardEntry>, Failure>> watchLeaderboard(String filter);

  /// Submits or updates the current user's score on the leaderboard.
  Future<Result<void, Failure>> submitScore({
    required int points,
    required double avgTime,
    required int streak,
  });

  /// Updates the current user's display name.
  Future<Result<void, Failure>> updateDisplayName(String displayName);
}
