// ignore_for_file: avoid_print

import 'package:just_audio/just_audio.dart';
import 'package:melocue/features/game/domain/services/audio_player_service.dart';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerServiceImpl({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  @override
  Future<void> load(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      // Typically throw a custom Exception or Failure depending on the architecture level.
      // We will let the BLoC catch this via a wrapper or try-catch in the usecase/bloc.
      throw Exception('Failed to load audio: $e');
    }
  }

  @override
  Future<void> playChunk(Duration duration) async {
    try {
      // Clear any existing clip that might have been set previously
      try {
        await _player.setClip(start: null, end: null);
      } catch (_) {}

      await _player.seek(Duration.zero);
      _player.play(); // DO NOT AWAIT, fire and forget

      print(
        '▶️ PLAYING CHUNK: Targeted duration is ${duration.inMilliseconds}ms',
      );

      // Listen to position stream to manually pause when chunk duration is reached
      await for (final pos in _player.positionStream) {
        if (pos >= duration) {
          print(
            '⏸️ PAUSING: Reached ${pos.inMilliseconds}ms (Target was ${duration.inMilliseconds}ms)',
          );
          await _player.pause();
          break;
        }
        // If user manually pauses before chunk ends, stop tracking
        if (!_player.playing) {
          print(
            '⏹️ STOPPED EARLY: Player stopped at ${pos.inMilliseconds}ms (playing state is false)',
          );
          break;
        }
      }
    } catch (e) {
      throw Exception('Failed to play audio chunk: $e');
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> replayChunk(Duration duration) async {
    await playChunk(duration);
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  void dispose() {
    _player.dispose();
  }
}
