import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _kCurrentStreak = 'currentStreak';
  static const String _kMaxStreak = 'maxStreak';
  static const String _kGamesPlayed = 'gamesPlayed';
  static const String _kGamesWon = 'gamesWon';
  static const String _kLastDailyDate = 'lastDailyDate';
  static const String _kCoins = 'melo_coins'; // New key for Coins

  // Emoji Mode Keys
  static const String _kEmojiUnlockedStages = 'emoji_unlocked_stages';
  static const String _kEmojiCurrentStage = 'emoji_current_stage';
  static const String _kEmojiCurrentIndex = 'emoji_current_index';

  final SharedPreferences _prefs;
  late final ValueNotifier<Locale> localeNotifier;
  late final ValueNotifier<int> coinNotifier;
  late final ValueNotifier<int> emojiUnlockedNotifier;
  late final ValueNotifier<String?> regionNotifier;

  LocalStorageService(this._prefs) {
    final storedLocale = _prefs.getString('language_code') ?? 'en';
    localeNotifier = ValueNotifier(Locale(storedLocale));

    // Initialize coin notifier
    int initialCoins = _prefs.getInt(_kCoins) ?? -1;
    if (initialCoins == -1) {
      _prefs.setInt(_kCoins, 100);
      initialCoins = 100;
    }
    coinNotifier = ValueNotifier(initialCoins);

    // Initialize emoji unlocked notifier
    final initialUnlocked = _prefs.getInt(_kEmojiUnlockedStages) ?? 1;
    emojiUnlockedNotifier = ValueNotifier(initialUnlocked);

    // Initialize region notifier
    regionNotifier = ValueNotifier(_prefs.getString('user_country_code'));
  }

  int get currentStreak => _prefs.getInt(_kCurrentStreak) ?? 0;

  Future<void> saveStreak(int streak) async {
    await _prefs.setInt(_kCurrentStreak, streak);

    // Update max streak if necessary
    final maxStreak = _prefs.getInt(_kMaxStreak) ?? 0;
    if (streak > maxStreak) {
      await _prefs.setInt(_kMaxStreak, streak);
    }
  }

  // --- Coins Economy --- //
  int get coins => coinNotifier.value;

  Future<void> addCoins(int amount) async {
    final current = coins;
    final newAmount = current + amount;
    await _prefs.setInt(_kCoins, newAmount);
    coinNotifier.value = newAmount;
  }

  Future<bool> deductCoins(int amount) async {
    final current = coins;
    if (current >= amount) {
      final newAmount = current - amount;
      await _prefs.setInt(_kCoins, newAmount);
      coinNotifier.value = newAmount;
      return true;
    }
    return false; // Not enough coins
  }

  Future<void> incrementGamesPlayed() async {
    final played = _prefs.getInt(_kGamesPlayed) ?? 0;
    await _prefs.setInt(_kGamesPlayed, played + 1);
  }

  Future<void> incrementGamesWon() async {
    final won = _prefs.getInt(_kGamesWon) ?? 0;
    await _prefs.setInt(_kGamesWon, won + 1);
  }

  // Getters for stats
  int get maxStreak => _prefs.getInt(_kMaxStreak) ?? 0;
  int get gamesPlayed => _prefs.getInt(_kGamesPlayed) ?? 0;
  int get gamesWon => _prefs.getInt(_kGamesWon) ?? 0;

  // Daily logic
  String? get lastDailyDate => _prefs.getString(_kLastDailyDate);

  Future<void> markDailyPlayedToday() async {
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _prefs.setString(_kLastDailyDate, dateString);
  }

  bool get hasPlayedDailyToday {
    final last = lastDailyDate;
    if (last == null) return false;

    final now = DateTime.now();
    final todayString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return last == todayString;
  }

  // --- Dynamic Modes Stats --- //

  // Fan Test High Scores
  int getFanTestHighScore(String artist) {
    return _prefs.getInt('fanTest_highscore_$artist') ?? 0;
  }

  Future<void> saveFanTestHighScore(String artist, int score) async {
    final currentScore = getFanTestHighScore(artist);
    if (score > currentScore) {
      await _prefs.setInt('fanTest_highscore_$artist', score);
    }
  }

  // Categories Stats
  int getCategoryPlayed(String category) {
    return _prefs.getInt('category_played_$category') ?? 0;
  }

  int getCategoryWon(String category) {
    return _prefs.getInt('category_won_$category') ?? 0;
  }

  Future<void> incrementCategoryPlayed(String category) async {
    final played = getCategoryPlayed(category);
    await _prefs.setInt('category_played_$category', played + 1);
  }

  Future<void> incrementCategoryWon(String category) async {
    final won = getCategoryWon(category);
    await _prefs.setInt('category_won_$category', won + 1);
  }

  // --- Guess Distribution --- //
  int getGuessCount(int chunkIndex) {
    return _prefs.getInt('guess_dist_$chunkIndex') ?? 0;
  }

  Future<void> incrementGuessCount(int chunkIndex) async {
    final count = getGuessCount(chunkIndex);
    await _prefs.setInt('guess_dist_$chunkIndex', count + 1);
  }

  // --- Last Solved Track --- //
  String? get lastSolvedTrackName => _prefs.getString('last_solved_name');
  String? get lastSolvedArtistName => _prefs.getString('last_solved_artist');
  String? get lastSolvedAlbumArt => _prefs.getString('last_solved_art');

  Future<void> saveLastSolvedTrack(
    String name,
    String artist,
    String artUrl,
  ) async {
    await _prefs.setString('last_solved_name', name);
    await _prefs.setString('last_solved_artist', artist);
    await _prefs.setString('last_solved_art', artUrl);
  }

  // --- Settings --- //
  bool get hapticsEnabled => _prefs.getBool('haptics_enabled') ?? true;
  Future<void> setHapticsEnabled(bool enabled) async {
    await _prefs.setBool('haptics_enabled', enabled);
  }

  bool get notificationsEnabled =>
      _prefs.getBool('notifications_enabled') ?? true;
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  String get languageCode => _prefs.getString('language_code') ?? 'en';
  Future<void> setLanguageCode(String code) async {
    await _prefs.setString('language_code', code);
    localeNotifier.value = Locale(code);
  }

  // --- Spotify Auth --- //
  String? get spotifyAccessToken => _prefs.getString('spotify_access_token');
  Future<void> setSpotifyAccessToken(String token) async {
    await _prefs.setString('spotify_access_token', token);
  }

  String? get spotifyRefreshToken => _prefs.getString('spotify_refresh_token');
  Future<void> setSpotifyRefreshToken(String token) async {
    await _prefs.setString('spotify_refresh_token', token);
  }

  Future<void> clearSpotifyAuth() async {
    await _prefs.remove('spotify_access_token');
    await _prefs.remove('spotify_refresh_token');
  }

  // --- Reset --- //
  Future<void> resetAllStats() async {
    // We want to keep auth and settings, but clear stats.
    final haptics = hapticsEnabled;
    final notifs = notificationsEnabled;
    final lang = languageCode;
    // Maybe keep XP and Level? The user might want a full reset. Let's just clear everything except Settings.

    await _prefs.clear();

    // Restore settings
    await setHapticsEnabled(haptics);
    await setNotificationsEnabled(notifs);
    await setLanguageCode(lang);
  }

  // --- Genre DNA --- //
  int getGenreCount(String genre) {
    return _prefs.getInt('genre_count_$genre') ?? 0;
  }

  Future<void> incrementGenreCount(String genre) async {
    final count = getGenreCount(genre);
    await _prefs.setInt('genre_count_$genre', count + 1);

    // Also track all unique genres seen
    final genresList = _prefs.getStringList('all_genres') ?? [];
    if (!genresList.contains(genre)) {
      genresList.add(genre);
      await _prefs.setStringList('all_genres', genresList);
    }
  }

  List<MapEntry<String, int>> getTopGenres() {
    final genresList = _prefs.getStringList('all_genres') ?? [];
    final counts = <String, int>{};
    for (final genre in genresList) {
      counts[genre] = getGenreCount(genre);
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  // Emoji Mode Getters/Setters
  int get unlockedEmojiStages => _prefs.getInt(_kEmojiUnlockedStages) ?? 1;
  bool get hasPremiumEmojiPass => _prefs.getBool('emoji_premium_pass') ?? false;

  Future<void> setPremiumEmojiPass(bool value) async {
    await _prefs.setBool('emoji_premium_pass', value);
  }

  Future<void> unlockEmojiStage(int stageNumber) async {
    final current = unlockedEmojiStages;
    if (stageNumber > current) {
      await _prefs.setInt(_kEmojiUnlockedStages, stageNumber);
      emojiUnlockedNotifier.value = stageNumber;
    }
  }

  int get currentEmojiStage => _prefs.getInt(_kEmojiCurrentStage) ?? 1;
  Future<void> saveCurrentEmojiStage(int stage) async {
    await _prefs.setInt(_kEmojiCurrentStage, stage);
  }

  int get currentEmojiIndex => _prefs.getInt(_kEmojiCurrentIndex) ?? 0;
  Future<void> saveCurrentEmojiIndex(int index) async {
    await _prefs.setInt(_kEmojiCurrentIndex, index);
  }

  // --- Location / Country --- //
  String? get countryCode => _prefs.getString('user_country_code');
  bool get isCountryManual => _prefs.getBool('is_country_manual') ?? false;

  Future<void> saveCountryCode(String code, {bool isManual = false}) async {
    await _prefs.setString('user_country_code', code);
    await _prefs.setBool('is_country_manual', isManual);
    regionNotifier.value = code;
  }
}
