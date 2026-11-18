import 'package:dio/dio.dart';
import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/core/utils/result.dart';
import 'package:melocue/features/game/data/datasources/itunes_remote_data_source.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';
import 'package:melocue/features/game/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final ItunesRemoteDataSource _remoteDataSource;

  GameRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<TrackEntity>, Failure>> fetchTracks({bool isDaily = false}) async {
    try {
      int? seed;
      if (isDaily) {
        final now = DateTime.now();
        seed = now.year * 10000 + now.month * 100 + now.day;
      }
      final trackModels = await _remoteDataSource.fetchPopularTracks(seed: seed);
      // TrackModel already extends TrackEntity
      return Success(trackModels);
    } on DioException catch (e) {
      // Map Dio errors to Network/Server Failures
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Error(NetworkFailure('Connection timed out.'));
      }
      return Error(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TrackEntity>, Failure>> fetchTracksByCategory(String category) async {
    try {
      final trackModels = await _remoteDataSource.fetchTracksByCategory(category);
      return Success(trackModels);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Error(NetworkFailure('Connection timed out.'));
      }
      return Error(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TrackEntity>, Failure>> fetchTracksByArtist(String artist) async {
    try {
      final trackModels = await _remoteDataSource.fetchTracksByArtist(artist);
      return Success(trackModels);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Error(NetworkFailure('Connection timed out.'));
      }
      return Error(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TrackEntity>, Failure>> searchTracks(String query) async {
    try {
      final trackModels = await _remoteDataSource.searchTracks(query);
      return Success(trackModels);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        return const Error(NetworkFailure('Connection timed out.'));
      }
      return Error(ServerFailure(e.message ?? 'Server error occurred.'));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
}
