import 'package:json_annotation/json_annotation.dart';
import 'package:melocue/features/game/data/models/track_model.dart';

part 'itunes_response_model.g.dart';

@JsonSerializable()
class ItunesResponseModel {
  final int resultCount;
  final List<TrackModel> results;

  const ItunesResponseModel({
    required this.resultCount,
    required this.results,
  });

  factory ItunesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ItunesResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ItunesResponseModelToJson(this);
}
