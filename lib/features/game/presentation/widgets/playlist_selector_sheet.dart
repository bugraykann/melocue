import 'package:flutter/material.dart';
import 'package:melocue/core/network/spotify_api_service.dart';
import 'package:melocue/core/utils/context_extensions.dart';
import 'package:dio/dio.dart';
import 'package:melocue/features/game/data/datasources/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melocue/features/game/domain/entities/game_mode.dart';
import 'package:melocue/features/game/presentation/bloc/game_bloc.dart';
import 'package:melocue/features/game/presentation/bloc/game_event.dart';
import 'package:go_router/go_router.dart';

class PlaylistSelectorSheet extends StatefulWidget {
  const PlaylistSelectorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const PlaylistSelectorSheet(),
    );
  }

  @override
  State<PlaylistSelectorSheet> createState() => _PlaylistSelectorSheetState();
}

class _PlaylistSelectorSheetState extends State<PlaylistSelectorSheet> {
  late final SpotifyApiService _spotifyService;
  List<Map<String, dynamic>> _playlists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _spotifyService = SpotifyApiService(Dio(), context.read<LocalStorageService>());
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playlists = await _spotifyService.getUserPlaylists();
      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startGameWithPlaylist(String playlistId) {
    Navigator.pop(context); // close sheet
    context.read<GameBloc>().add(
      GameStarted(
        mode: GameMode.myPlaylist,
        modeParameter: playlistId,
      ),
    );
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(0.75), // 75% of screen height
      decoration: const BoxDecoration(
        color: Color(0xFF151219),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Icon(Icons.music_note_rounded, color: Color(0xFF1ED760)),
                const SizedBox(width: 8),
                Text(
                  context.l10n.spotifyPlaylistsTitle,
                  style: context.typography.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1ED760)),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            )
          else if (_playlists.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  context.l10n.noPlaylistsFound,
                  style: context.typography.bodyLarge?.copyWith(color: const Color(0xFFB3B3B3)),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final p = _playlists[index];
                  final images = p['images'] as List?;
                  final imageUrl = images != null && images.isNotEmpty ? images.first['url'] : null;
                  
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A35),
                          borderRadius: BorderRadius.circular(8),
                          image: imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        p['name'] ?? context.l10n.unknownPlaylist,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: p['total_tracks'] != null && p['total_tracks'] > 0
                          ? Text(
                              context.l10n.songCountText(p['total_tracks']),
                              style: const TextStyle(color: Color(0xFFB3B3B3)),
                            )
                          : Text(
                              context.l10n.songsLabel,
                              style: const TextStyle(color: Color(0xFFB3B3B3)),
                            ),
                      trailing: const Icon(Icons.play_arrow_rounded, color: Color(0xFF1ED760)),
                      onTap: () => _startGameWithPlaylist(p['id']),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
