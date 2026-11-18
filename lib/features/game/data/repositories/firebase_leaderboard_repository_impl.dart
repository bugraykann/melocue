import 'dart:ui';

// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:melocue/core/utils/failure.dart';
import 'package:melocue/core/utils/result.dart';
import 'package:melocue/features/game/domain/entities/leaderboard_entry.dart';
import 'package:melocue/features/game/domain/repositories/leaderboard_repository.dart';

class FirebaseLeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseLeaderboardRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  Future<User> _getOrSignInUser() async {
    final user = _auth.currentUser;
    if (user != null) return user;
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user!;
  }

  @override
  Stream<Result<List<LeaderboardEntry>, Failure>> watchLeaderboard(
    String filter,
  ) async* {
    try {
      final user = await _getOrSignInUser();
      final currentUid = user.uid;

      // Ensure the user document exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUid)
          .get();
      if (!userDoc.exists) {
        // Initialize an empty user profile if it doesn't exist
        await _firestore.collection('users').doc(currentUid).set({
          'uid': currentUid,
          'displayName': 'Guest_${currentUid.substring(0, 5)}',
          'points': 0,
          'avgTime': 0.0,
          'streak': 0,
          'avatarColor': 0xFF1ED760, // Default green
          'isVip': false,
        });
      }

      // Query the leaderboard (top 50 users by points)
      final query = _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(50);

      yield* query.snapshots().map((snapshot) {
        try {
          final entries = snapshot.docs.map((doc) {
            final data = doc.data();
            return LeaderboardEntry(
              uid: data['uid'] ?? doc.id,
              displayName: data['displayName'] ?? 'Unknown',
              points: (data['points'] ?? 0).toInt(),
              avgTime: (data['avgTime'] ?? 0.0).toDouble(),
              streak: (data['streak'] ?? 0).toInt(),
              avatarColor: Color((data['avatarColor'] ?? 0xFF1ED760).toInt()),
              isVip: data['isVip'] ?? false,
            );
          }).toList();
          return Success(entries);
        } catch (e) {
          print('Error parsing leaderboard data: $e');
          return Error(UnknownFailure('Error parsing data: $e'));
        }
      });
    } catch (e) {
      print('Failed to fetch leaderboard: $e');
      yield Error(UnknownFailure('Failed to fetch: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> submitScore({
    required int points,
    required double avgTime,
    required int streak,
  }) async {
    try {
      final user = await _getOrSignInUser();
      await _firestore.collection('users').doc(user.uid).set({
        'points': FieldValue.increment(points),
        'avgTime': avgTime,
        'streak': streak,
      }, SetOptions(merge: true));
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to update score: $e'));
    }
  }

  @override
  Future<Result<void, Failure>> updateDisplayName(String displayName) async {
    try {
      final user = await _getOrSignInUser();
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
      }, SetOptions(merge: true));
      return const Success(null);
    } catch (e) {
      return Error(UnknownFailure('Failed to update display name: $e'));
    }
  }
}
