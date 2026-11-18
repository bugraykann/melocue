import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VisualScene {
  final String id;
  final int hintLevel;
  final String assetType;
  final String style;
  final String scenePrompt;
  final String animationSuggestion;
  final String layout;

  const VisualScene({
    required this.id,
    required this.hintLevel,
    required this.assetType,
    required this.style,
    required this.scenePrompt,
    required this.animationSuggestion,
    required this.layout,
  });

  String get assetPath => 'assets/images/song_clues/$id.jpg';

  factory VisualScene.fromJson(Map<String, dynamic> json) {
    return VisualScene(
      id: json['id'] as String? ?? '',
      hintLevel: json['hintLevel'] as int? ?? 1,
      assetType: json['assetType'] as String? ?? '',
      style: json['style'] as String? ?? '',
      scenePrompt: json['scenePrompt'] as String? ?? '',
      animationSuggestion: json['animationSuggestion'] as String? ?? '',
      layout: json['layout'] as String? ?? '',
    );
  }
}

class EmojiQuestion {
  final String emojis;
  final String? imagePath;
  final String answer;
  final String artist;
  final String? lyric;
  final String? visualMode;
  final int? visualCount;
  final List<VisualScene>? visualScenes;

  const EmojiQuestion({
    required this.emojis,
    this.imagePath,
    required this.answer,
    required this.artist,
    this.lyric,
    this.visualMode,
    this.visualCount,
    this.visualScenes,
  });

  factory EmojiQuestion.fromJson(Map<String, dynamic> json) {
    List<VisualScene>? parsedScenes;
    if (json['visualScenes'] != null) {
      final scenesList = json['visualScenes'] as List;
      parsedScenes = scenesList
          .map((s) => VisualScene.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return EmojiQuestion(
      emojis: json['emojis'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      answer: json['answer'] as String,
      artist: json['artist'] as String,
      lyric: json['lyric'] as String?,
      visualMode: json['visualMode'] as String?,
      visualCount: json['visualCount'] as int?,
      visualScenes: parsedScenes,
    );
  }
}

class EmojiStage {
  final int stageNumber;
  final List<EmojiQuestion> questions;

  const EmojiStage({required this.stageNumber, required this.questions});

  factory EmojiStage.fromJson(Map<String, dynamic> json) {
    final questionsList = json['questions'] as List;
    final questions = questionsList
        .map((q) => EmojiQuestion.fromJson(q as Map<String, dynamic>))
        .toList();

    return EmojiStage(stageNumber: json['stage'] as int, questions: questions);
  }
}

Future<List<EmojiStage>> loadEmojiStagesData(String? countryCode) async {
  String path = 'assets/data/emoji_global.json';
  if (countryCode?.toUpperCase() == 'TR') {
    path = 'assets/data/sarki_tahmin_ozgun_gorsel_manifesti.json';
  }

  try {
    final jsonString = await rootBundle.loadString(path);
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData
        .map((stage) => EmojiStage.fromJson(stage as Map<String, dynamic>))
        .toList();
  } catch (e) {
    if (kDebugMode) {
      print("Error loading emoji data: $e");
    }
    // Fallback if file not found or parse error
    return [];
  }
}
