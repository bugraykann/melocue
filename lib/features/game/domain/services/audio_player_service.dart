import 'package:just_audio/just_audio.dart';

abstract class AudioPlayerService {
  /// Loads audio from a URL.
  Future<void> load(String url);

  /// Plays the audio from the beginning up to the specified [duration] and pauses.
  Future<void> playChunk(Duration duration);

  /// Stops or pauses the playback.
  Future<void> pause();
  
  /// Replays the current loaded chunk from the beginning.
  Future<void> replayChunk(Duration duration);

  /// Streams the current playback position.
  Stream<Duration> get positionStream;

  /// Streams the player state (playing, paused, buffering, etc).
  Stream<PlayerState> get playerStateStream;
  
  /// Streams the buffering progression (useful for loading UI).
  Stream<Duration> get bufferedPositionStream;

  /// Clean up resources.
  void dispose();
}
