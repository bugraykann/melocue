// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SonicGuess';

  @override
  String get playButton => 'Play';

  @override
  String skipButton(int seconds) {
    return 'Skip (+${seconds}s)';
  }

  @override
  String get loopButton => 'Loop';

  @override
  String get guessInputPlaceholder => 'Guess song or artist name...';

  @override
  String get submitButton => 'Submit';

  @override
  String get congratulations => 'CONGRATULATIONS! 🎉';

  @override
  String get goodTry => 'GOOD TRY! 🥲';

  @override
  String completedSeries(int rounds) {
    return 'You completed the $rounds-song series!';
  }

  @override
  String get correctLabel => 'CORRECT';

  @override
  String get successRateLabel => 'SUCCESS';

  @override
  String get xpEarnedLabel => 'XP EARNED';

  @override
  String get sessionSummary => 'SESSION SUMMARY';

  @override
  String get returnToModes => 'Return to Modes';

  @override
  String get playAgain => 'Play Again';

  @override
  String get correctGuess => 'Correct Guess!';

  @override
  String get wrongGuess => 'Wrong Guess!';

  @override
  String get subtitleTagline => 'Guess the song in 6 attempts';

  @override
  String get dailyChallengePlayed =>
      'You have already played today\'s Daily Challenge. Come back tomorrow!';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get navModes => 'Modes';

  @override
  String get navRanks => 'Ranks';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get modesTitle => 'Modes';

  @override
  String get gameModes => 'Game Modes';

  @override
  String get modesSubtitle => 'Zero wait time. Pick a mode and play.';

  @override
  String get unlimitedBadge => 'UNLIMITED';

  @override
  String get noviceListener => 'Novice Listener';

  @override
  String get connectSpotifyFirst =>
      'Please connect your Spotify account in settings first.';

  @override
  String get myPlaylist => 'From My Playlist';

  @override
  String get endlessMode => 'Endless Mode';

  @override
  String get fanTests => 'Fan Tests';

  @override
  String get popular => 'Popular';

  @override
  String get tenSongs => '10 SONGS';

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get filterAll => 'All';

  @override
  String get filterTurkish => 'Turkish';

  @override
  String get filterForeign => 'Foreign';

  @override
  String get filterNostalgia => 'Nostalgic';

  @override
  String get filterRap => 'Rap';

  @override
  String get filterRock => 'Rock';

  @override
  String get filterRb => 'R&B';

  @override
  String get filterKpop => 'K-Pop';

  @override
  String get filterIndie => 'Indie';

  @override
  String get filterLatin => 'Latin';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String recordScore(int score) {
    return 'Record: $score';
  }

  @override
  String get badgeNew => 'New';

  @override
  String get badgeGlobal => 'Global';

  @override
  String get badgePopular => 'Popular';

  @override
  String get badgeNostalgia => 'Nostalgia';

  @override
  String get fanTestTarkanTitle => 'Tarkan';

  @override
  String get fanTestTarkanDesc => 'Guess the Megastar\'s 10 songs the fastest.';

  @override
  String get fanTestSezenTitle => 'Sezen Aksu';

  @override
  String get fanTestSezenDesc => 'Little Sparrow classics back to back.';

  @override
  String get fanTestMuslumTitle => 'Müslüm Gürses';

  @override
  String get fanTestMuslumDesc =>
      'The father of Arabesque, the deepest 10 songs.';

  @override
  String get fanTestManifestTitle => 'Manifest';

  @override
  String get fanTestManifestDesc =>
      'Turkish girl group hits: Snap, Amatör and more.';

  @override
  String get fanTestBlok3Title => 'Blok3';

  @override
  String get fanTestBlok3Desc =>
      '10 tracks that dominated the era. How many do you know?';

  @override
  String get fanTestLvbelTitle => 'Lvbel C5';

  @override
  String get fanTestLvbelDesc => 'Street music\'s hardest 10 tracks.';

  @override
  String get fanTestCezaTitle => 'Ceza';

  @override
  String get fanTestCezaDesc => 'The legend of Turkish rap. 10 classic tracks.';

  @override
  String get fanTestUziTitle => 'Uzi';

  @override
  String get fanTestUziDesc =>
      'Pioneer of the trap scene. 10 tracks await you.';

  @override
  String get genreTurkPopTitle => 'Turkish Pop';

  @override
  String get genreTurkPopDesc => 'Sezen Aksu, Tarkan, Gülşen, Kenan Doğulu...';

  @override
  String get genreTurkRapTitle => 'Turkish Rap';

  @override
  String get genreTurkRapDesc => 'Ezhel, Ceza, Sagopa Kajmer, Uzi, Motive...';

  @override
  String get genre2000PopTitle => '2000s Turkish Pop';

  @override
  String get genre2000PopDesc =>
      'Hepsi, Hande Yener, Demet Akalın, Serdar Ortaç';

  @override
  String get genreGlobalPopTitle => 'Global Pop';

  @override
  String get genreGlobalPopDesc =>
      'The Weeknd, Taylor Swift, Dua Lipa, Ed Sheeran';

  @override
  String get genreRockTitle => 'Rock Classics';

  @override
  String get genreRockDesc => 'Queen, AC/DC, Nirvana, The Rolling Stones';

  @override
  String get genreRbTitle => 'R&B / Soul';

  @override
  String get genreRbDesc => 'Bruno Mars, The Weeknd, Alicia Keys, Usher';

  @override
  String get genreKpopTitle => 'K-Pop';

  @override
  String get genreKpopDesc => 'BTS, BLACKPINK, EXO, TWICE';

  @override
  String get genreIndieTitle => 'Indie & Alternative';

  @override
  String get genreIndieDesc => 'Arctic Monkeys, Tame Impala, The Strokes';

  @override
  String get genreLatinTitle => 'Latin Hits';

  @override
  String get genreLatinDesc => 'Bad Bunny, J Balvin, Shakira, Rosalía';

  @override
  String get leaderboardsTitle => 'Leaderboards';

  @override
  String get leaderboardsSubtitle =>
      'Compete daily, earn bragging rights & badges';

  @override
  String get noPlayersYet => 'No players yet.';

  @override
  String failedToLoadRanks(String error) {
    return 'Failed to load ranks:\n$error';
  }

  @override
  String get soundDeity => 'SOUND DEITY';

  @override
  String get points => 'pts';

  @override
  String get average => 'avg';

  @override
  String get streak => 'Streak';

  @override
  String youRankText(String name) {
    return 'You ($name)';
  }

  @override
  String get vipBadge => 'VIP';

  @override
  String get topFivePercent => 'Top 5%';

  @override
  String get compareBtn => 'Compare';

  @override
  String get rankAndPlayer => 'RANK & PLAYER';

  @override
  String get pointsAndStreak => 'POINTS / STREAK';

  @override
  String avgAndDailyText(String avg) {
    return 'Avg $avg • Daily #184: 1st Guess';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get resetAllDataTitle => 'Reset All Data';

  @override
  String get resetAllDataDesc =>
      'Are you sure you want to reset all your stats and progress? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get dataResetSuccess => 'All data has been reset.';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get haptics => 'Haptics';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get resetAllDataBtn => 'Reset All Data';

  @override
  String get connectedAccounts => 'Connected Accounts';

  @override
  String get connected => 'Connected';

  @override
  String get tapToConnect => 'Tap to connect';

  @override
  String get logout => 'Logout';

  @override
  String get spotifyConnected => 'Spotify connected successfully!';

  @override
  String get spotifyConnectionFailed => 'Connection failed.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get player => 'Player';

  @override
  String get novice => 'Novice';

  @override
  String get risingStar => 'Rising Star';

  @override
  String get soundMaestro => 'Sound Maestro';

  @override
  String get musicDeity => 'Music Deity';

  @override
  String lvlText(int level) {
    return 'LVL $level';
  }

  @override
  String levelProgressText(int current, int next) {
    return 'Level $current → Level $next';
  }

  @override
  String xpProgressText(int current, int next) {
    return '$current / $next XP';
  }

  @override
  String xpToNextLevel(int xp, int level) {
    return '$xp XP to Level $level';
  }

  @override
  String totalXp(int xp) {
    return 'Total: $xp XP';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get challenges => 'Challenges';

  @override
  String get totalPlayed => 'Total Played';

  @override
  String get winRate => 'Win Rate';

  @override
  String solvedCount(int count) {
    return '$count Solved';
  }

  @override
  String get currentStreakTitle => 'Current Streak';

  @override
  String get days => 'Days';

  @override
  String get activeDays => 'Active Days';

  @override
  String get bestStreakTitle => 'Best Streak';

  @override
  String get allTimeHigh => 'All Time High';

  @override
  String get guessDistribution => 'Guess Distribution';

  @override
  String get guessDistributionDesc => 'Frequency by snippet duration';

  @override
  String get fail => 'Fail';

  @override
  String get peak => '(Peak)';

  @override
  String get genreDna => 'Genre DNA';

  @override
  String get genreDnaDesc => 'Ear calibration by musical territory';

  @override
  String get diamond => 'Diamond';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get bronze => 'Bronze';

  @override
  String get lastSolvedVictory => 'Last Solved Victory';

  @override
  String get recent => 'Recent';

  @override
  String get editProfileDialogTitle => 'Edit Profile';

  @override
  String get editProfileDialogDesc =>
      'Choose your display name for the leaderboards.';

  @override
  String get newNameHint => 'Your new name...';

  @override
  String get nameUpdatedSuccess => 'Your name has been updated successfully!';

  @override
  String get save => 'Save';

  @override
  String get category => 'Category';

  @override
  String fanTestTitle(String name) {
    return 'Fan Test: $name';
  }

  @override
  String dailyBadgeText(int number) {
    return 'DAILY #$number';
  }

  @override
  String snippetDuration(String duration) {
    return '$duration snippet';
  }

  @override
  String guessCountText(int current, int max) {
    return 'Guess $current/$max';
  }

  @override
  String get correctlyGuessed => 'Correctly Guessed';

  @override
  String get skipped => 'Skipped';

  @override
  String get wronglyGuessed => 'Wrongly Guessed';

  @override
  String get skipAction => 'Skip';

  @override
  String get genreHintUnlockedAt => 'Genre hint unlocked at 4.0s';

  @override
  String get howToPlay => 'How to play ';

  @override
  String get snippetProgression => 'SNIPPET PROGRESSION';

  @override
  String stageProgression(int current, int total) {
    return 'Stage $current of $total';
  }

  @override
  String get statisticsUpper => 'STATISTICS';

  @override
  String get playedLabel => 'Played';

  @override
  String get winPercentageLabel => 'Win %';

  @override
  String get currentStreakLabel => 'Current\nStreak';

  @override
  String get maxStreakLabel => 'Max\nStreak';

  @override
  String get spotifyPlaylistsTitle => 'Your Spotify Playlists';

  @override
  String get noPlaylistsFound => 'No playlists found.';

  @override
  String get unknownPlaylist => 'Unknown Playlist';

  @override
  String songCountText(int count) {
    return '$count Songs';
  }

  @override
  String get songsLabel => 'Songs';

  @override
  String get emojiModeTitle => 'Emoji Mode';

  @override
  String get stageUnlockDialogTitle => 'Unlock Stage';

  @override
  String stageUnlockDialogDesc(int stage) {
    return 'You need 200 MeloCoins to unlock Stage $stage.';
  }

  @override
  String get payCoinButton => 'Pay 200 Coins';

  @override
  String get notEnoughCoins => 'Not enough coins!';

  @override
  String get emojiStageCompleted =>
      'Congratulations! You completed the stage! 🏆';

  @override
  String get emojiAllStagesCompleted =>
      'YOU BEAT THE GAME! BIG REWARD COMING SOON! 👑';

  @override
  String stageAndQuestionProgress(int stage, int question) {
    return 'Stage $stage • Question $question/10';
  }

  @override
  String wrongGuessLabel(String guess) {
    return 'Wrong Guess: $guess';
  }

  @override
  String artistLabel(String artist) {
    return 'Artist: $artist';
  }

  @override
  String get jokersTitle => 'Jokers';

  @override
  String get revealLetter => 'Reveal Letter';

  @override
  String get revealArtist => 'Reveal Artist';

  @override
  String get giveUpAndSkip => 'Give Up & Skip';

  @override
  String stageTitle(int stage) {
    return 'Stage $stage';
  }
}
