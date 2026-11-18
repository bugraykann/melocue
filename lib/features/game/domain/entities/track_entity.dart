import 'package:equatable/equatable.dart';

class TrackEntity extends Equatable {
  final int trackId;
  final String trackName;
  final String artistName;
  final String albumArtUrl;
  final String previewUrl;
  final String? genre;

  const TrackEntity({
    required this.trackId,
    required this.trackName,
    required this.artistName,
    required this.albumArtUrl,
    required this.previewUrl,
    this.genre,
  });

  @override
  List<Object?> get props => [
        trackId,
        trackName,
        artistName,
        albumArtUrl,
        previewUrl,
        genre,
      ];
}
