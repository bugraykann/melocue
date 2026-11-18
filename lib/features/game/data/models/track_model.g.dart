// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackModel _$TrackModelFromJson(Map<String, dynamic> json) => TrackModel(
  trackId: (json['trackId'] as num).toInt(),
  trackName: json['trackName'] as String,
  artistName: json['artistName'] as String,
  albumArtUrl: json['artworkUrl100'] as String,
  previewUrl: json['previewUrl'] as String,
  genre: json['primaryGenreName'] as String?,
);

Map<String, dynamic> _$TrackModelToJson(TrackModel instance) =>
    <String, dynamic>{
      'trackId': instance.trackId,
      'trackName': instance.trackName,
      'artistName': instance.artistName,
      'artworkUrl100': instance.albumArtUrl,
      'previewUrl': instance.previewUrl,
      'primaryGenreName': instance.genre,
    };
