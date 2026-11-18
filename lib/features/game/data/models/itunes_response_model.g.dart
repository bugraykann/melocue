// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itunes_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItunesResponseModel _$ItunesResponseModelFromJson(Map<String, dynamic> json) =>
    ItunesResponseModel(
      resultCount: (json['resultCount'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => TrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItunesResponseModelToJson(
  ItunesResponseModel instance,
) => <String, dynamic>{
  'resultCount': instance.resultCount,
  'results': instance.results,
};
