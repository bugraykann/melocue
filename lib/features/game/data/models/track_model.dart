import 'package:json_annotation/json_annotation.dart';
import 'package:melocue/features/game/domain/entities/track_entity.dart';

part 'track_model.g.dart';

@JsonSerializable()
class TrackModel extends TrackEntity {
  const TrackModel({
    required super.trackId,
    required super.trackName,
    required super.artistName,
    @JsonKey(name: 'artworkUrl100') required super.albumArtUrl,
    required super.previewUrl,
    @JsonKey(name: 'primaryGenreName') super.genre,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> mutableJson = Map<String, dynamic>.from(json);
    
    if (mutableJson['trackName'] is String) {
      String name = mutableJson['trackName'] as String;
      // Remove text inside parentheses (e.g., "(Feat. XYZ)", "(Live)")
      name = name.replaceAll(RegExp(r'\(.*?\)'), '');
      // Remove text inside brackets
      name = name.replaceAll(RegExp(r'\[.*?\]'), '');
      // Remove subtitles starting with " - " (e.g., " - Remastered")
      if (name.contains(' - ')) {
        name = name.split(' - ').first;
      }
      mutableJson['trackName'] = name.trim();
    }
    
    return _$TrackModelFromJson(mutableJson);
  }

  Map<String, dynamic> toJson() => _$TrackModelToJson(this);
}
