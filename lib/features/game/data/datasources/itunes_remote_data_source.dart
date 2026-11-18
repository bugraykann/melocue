import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:melocue/core/network/dio_client.dart';
import 'package:melocue/features/game/data/models/itunes_response_model.dart';
import 'package:melocue/features/game/data/models/track_model.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

abstract class ItunesRemoteDataSource {
  Future<List<TrackModel>> fetchPopularTracks({int? seed});
  Future<List<TrackModel>> fetchTracksByCategory(String category);
  Future<List<TrackModel>> fetchTracksByArtist(String artist);
  Future<List<TrackModel>> searchTracks(String query);
}

class ItunesRemoteDataSourceImpl implements ItunesRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorageService _storageService;

  ItunesRemoteDataSourceImpl(this._dioClient, this._storageService);

  @override
  Future<List<TrackModel>> fetchPopularTracks({int? seed}) async {
    try {
      final country = (_storageService.countryCode ?? 'US').toLowerCase();
      
      List<String> terms;
      switch (country) {
        case 'tr':
          terms = ['türkçe pop', 'türkçe rap', 'türkçe rock', 'arabesk', 'türk sanat müziği', 'alternatif'];
          break;
        case 'de':
          terms = ['deutschrap', 'schlager', 'german pop', 'german rock', 'hip hop'];
          break;
        case 'fr':
          terms = ['variété française', 'french rap', 'chanson', 'french pop', 'r&b'];
          break;
        case 'it':
          terms = ['pop italiano', 'rap italiano', 'indie italia', 'trap', 'rock'];
          break;
        case 'es':
        case 'mx':
        case 'ar':
        case 'co':
          terms = ['pop latino', 'reggaeton', 'latin', 'bachata', 'trap latino'];
          break;
        case 'jp':
          terms = ['j-pop', 'j-rock', 'anime', 'vocaloid', 'city pop'];
          break;
        case 'kr':
          terms = ['k-pop', 'k-r&b', 'k-hip hop', 'k-indie'];
          break;
        case 'in':
          terms = ['bollywood', 'punjabi', 'desi hip hop', 'sufi', 'indian pop'];
          break;
        case 'br':
          terms = ['sertanejo', 'funk carioca', 'mpb', 'pagode', 'bossa nova', 'pop'];
          break;
        case 'gr':
          terms = ['laiko', 'greek pop', 'entechno', 'greek rap'];
          break;
        case 'lt':
          terms = ['lithuanian pop', 'lithuanian rap', 'lithuanian indie', 'pop'];
          break;
        default:
          terms = [
            'pop', 'rock', 'hip hop', 'r&b', 'jazz', 'electronic', 'indie', 'alternative'
          ];
      }

      final random = seed != null ? Random(seed) : Random();
      final randomTerm = terms[random.nextInt(terms.length)];

      final response = await _dioClient.dio.get(
        '/search',
        queryParameters: {
          'term': randomTerm,
          'media': 'music',
          'entity': 'song',
          'country': country,
          'limit': 50, // Fetch more to shuffle and filter
        },
      );

      // Parse JSON
      var data = response.data;
      if (data is String) {
        // iTunes API often returns text/javascript content-type, which Dio treats as a String.
        data = jsonDecode(data);
      }
      
      final itunesResponse = ItunesResponseModel.fromJson(data);
      
      // Filter out tracks without a previewUrl
      final validTracks = itunesResponse.results
          .where((track) => track.previewUrl.isNotEmpty)
          .toList();
          
      validTracks.shuffle(seed != null ? Random(seed) : Random());
          
      // Take only top 5 for the MVP test
      return validTracks.take(5).toList();
    } on DioException catch (e) {
      // Re-throw to be caught by the repository
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<TrackModel>> fetchTracksByCategory(String category) async {
    try {
      final country = (_storageService.countryCode ?? 'US').toLowerCase();

      final response = await _dioClient.dio.get(
        '/search',
        queryParameters: {
          'term': category,
          'media': 'music',
          'entity': 'song',
          'country': country,
          'limit': 50,
        },
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      final itunesResponse = ItunesResponseModel.fromJson(data);
      
      final validTracks = itunesResponse.results
          .where((track) => track.previewUrl.isNotEmpty)
          .toList();
          
      validTracks.shuffle();
      return validTracks.take(5).toList(); // MVP Limit
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Known song titles for artists where iTunes search by name is ambiguous.
  // We search song-by-song and build the tracklist manually.
  static const Map<String, List<String>> _curatedArtistSongs = {
    'Manifest': [
      'KTS', 'Arıyo', 'RÜYA', 'Snap', 'Amatör', 'Yaşanacaksa',
      'Güneş', 'Büyü', 'Dans', 'manifestival',
    ],
    'Blok3': [
      'Yakamoz', 'Hadi', 'Çağır', 'Sana Göre', 'Yanlış Yapma',
      'Bazen', 'Unut Gitsin', 'Kafam Güzel', 'Son Gece', 'Geçmişte Kal',
    ],
  };

  @override
  Future<List<TrackModel>> fetchTracksByArtist(String artist) async {
    // If this artist has a curated list, search song by song for accuracy
    final curatedSongs = _curatedArtistSongs[artist];
    if (curatedSongs != null) {
      return _fetchCuratedArtistTracks(artist, curatedSongs);
    }

    try {
      final country = (_storageService.countryCode ?? 'US').toLowerCase();

      final response = await _dioClient.dio.get(
        '/search',
        queryParameters: {
          'term': artist,
          'media': 'music',
          'entity': 'song',
          'attribute': 'artistTerm',
          'country': country,
          'limit': 50,
        },
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      final itunesResponse = ItunesResponseModel.fromJson(data);
      
      final validTracks = itunesResponse.results
          .where((track) => track.previewUrl.isNotEmpty)
          .toList();
          
      validTracks.shuffle();
      // Fan test has 10 tracks
      return validTracks.take(10).toList();
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<TrackModel>> _fetchCuratedArtistTracks(
    String artist,
    List<String> songTitles,
  ) async {
    final country = (_storageService.countryCode ?? 'US').toLowerCase();
    final tracks = <TrackModel>[];
    for (final title in songTitles) {
      if (tracks.length >= 10) break;
      try {
        final response = await _dioClient.dio.get(
          '/search',
          queryParameters: {
            'term': '$artist $title',
            'media': 'music',
            'entity': 'song',
            'country': country,
            'limit': 5,
          },
        );
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        final parsed = ItunesResponseModel.fromJson(data);
        final match = parsed.results.where((t) {
          final artistLower = t.artistName.toLowerCase();
          return artistLower.contains(artist.toLowerCase()) &&
              t.previewUrl.isNotEmpty;
        }).toList();
        if (match.isNotEmpty) {
          tracks.add(match.first);
        }
      } catch (_) {
        // Skip failed searches silently
      }
    }
    tracks.shuffle();
    return tracks;
  }


  @override
  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final country = (_storageService.countryCode ?? 'US').toLowerCase();

      final response = await _dioClient.dio.get(
        '/search',
        queryParameters: {
          'term': query,
          'media': 'music',
          'entity': 'song',
          'country': country,
          'limit': 10,
        },
      );

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      final itunesResponse = ItunesResponseModel.fromJson(data);
      return itunesResponse.results;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
