import 'dart:math';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';

class SpotifyApiService {
  final Dio _dio;
  final LocalStorageService _storage;

  // Replace this with the real Client ID from the developer dashboard
  static const String _clientId = '386c45bfb99144c38357a5df1e26a20a';
  static const String _redirectUri = 'melocue://callback';

  SpotifyApiService(this._dio, this._storage) {
    _dio.options.baseUrl = 'https://api.spotify.com/v1';
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Initiates the OAuth flow to authenticate the user and get a token.
  Future<bool> authenticate() async {
    try {
      final verifier = _generateCodeVerifier();
      final challenge = _generateCodeChallenge(verifier);

      // 1. Construct the authorization URL
      final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
        'client_id': _clientId,
        'response_type': 'code', // Using Authorization Code Flow with PKCE
        'redirect_uri': _redirectUri,
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
        'scope': 'user-library-read user-top-read user-read-recently-played',
      }).toString();

      // 2. Open the browser and wait for callback
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'melocue',
      );

      // 3. Parse the authorization code
      final parsedUri = Uri.parse(result.replaceFirst('#', '?'));
      final code = parsedUri.queryParameters['code'];

      if (code != null && code.isNotEmpty) {
        // 4. Exchange code for access token
        final tokenResponse = await _dio.post(
          'https://accounts.spotify.com/api/token',
          data: {
            'client_id': _clientId,
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': _redirectUri,
            'code_verifier': verifier,
          },
          options: Options(
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          ),
        );

        final accessToken = tokenResponse.data['access_token'];
        final refreshToken = tokenResponse.data['refresh_token'];

        if (accessToken != null) {
          await _storage.setSpotifyAccessToken(accessToken);
          if (refreshToken != null) {
            await _storage.setSpotifyRefreshToken(refreshToken);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception('Spotify bağlantı hatası: $e');
    }
  }

  /// Logout from Spotify
  Future<void> logout() async {
    await _storage.clearSpotifyAuth();
  }

  /// Get headers for authenticated requests
  Options _getAuthOptions() {
    final token = _storage.spotifyAccessToken;
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Fetch user's track collections (mocked as playlists)
  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    // We bypass Spotify's restricted Playlist API and use personal tracks!
    return [
      {
        'id': 'liked',
        'name': 'Beğenilen Şarkılar',
        'images': [],
        'total_tracks': -1,
      },
      {
        'id': 'top',
        'name': 'En Çok Dinlediklerim',
        'images': [],
        'total_tracks': -1,
      },
      {
        'id': 'recent',
        'name': 'Son Çalınanlar',
        'images': [],
        'total_tracks': -1,
      },
    ];
  }

  /// Fetch track names from personal collections
  Future<List<String>> getPlaylistTrackNames(String playlistId) async {
    try {
      String endpoint;
      if (playlistId == 'liked') {
        endpoint = '/me/tracks';
      } else if (playlistId == 'top') {
        endpoint = '/me/top/tracks';
      } else if (playlistId == 'recent') {
        endpoint = '/me/player/recently-played';
      } else {
        return [];
      }

      final response = await _dio.get(
        endpoint,
        queryParameters: {'limit': 50},
        options: _getAuthOptions(),
      );
      final items = response.data['items'] as List;

      List<String> trackNames = [];
      for (var item in items) {
        if (item != null) {
          final trackNode = (playlistId == 'top') ? item : item['track'];
          if (trackNode != null) {
            final trackName = trackNode['name'] ?? '';
            final artists = trackNode['artists'] as List?;
            final artistName = (artists != null && artists.isNotEmpty)
                ? (artists.first['name'] ?? '')
                : '';

            if (trackName.toString().isNotEmpty) {
              trackNames.add('$trackName $artistName');
            }
          }
        }
      }
      return trackNames;
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'API Hatası: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Şarkılar alınamadı: $e');
    }
  }
}
