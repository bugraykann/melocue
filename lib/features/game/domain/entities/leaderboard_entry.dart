import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LeaderboardEntry extends Equatable {
  final String uid;
  final String displayName;
  final int points;
  final double avgTime;
  final int streak;
  final Color avatarColor;
  final bool isVip;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.points,
    required this.avgTime,
    required this.streak,
    required this.avatarColor,
    this.isVip = false,
  });

  @override
  List<Object?> get props => [
        uid,
        displayName,
        points,
        avgTime,
        streak,
        avatarColor,
        isVip,
      ];
}
