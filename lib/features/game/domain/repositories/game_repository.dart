import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/core/utils/result.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';

abstract class GameRepository {
  /// Fetches a list of tracks to be used in the game.
  Future<Result<List<TrackEntity>, Failure>> fetchTracks({bool isDaily = false});

  Future<Result<List<TrackEntity>, Failure>> fetchTracksByCategory(String category);
  Future<Result<List<TrackEntity>, Failure>> fetchTracksByArtist(String artist);

  /// Searches tracks by query for autocomplete.
  Future<Result<List<TrackEntity>, Failure>> searchTracks(String query);
}
