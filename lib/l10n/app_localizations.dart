import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SonicGuess'**
  String get appName;

  /// Label for the play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// Label for the skip button
  ///
  /// In en, this message translates to:
  /// **'Skip (+{seconds}s)'**
  String skipButton(int seconds);

  /// Label for the loop button
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loopButton;

  /// Placeholder for the search input field
  ///
  /// In en, this message translates to:
  /// **'Guess song or artist name...'**
  String get guessInputPlaceholder;

  /// Label for the submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Congratulations message for winning
  ///
  /// In en, this message translates to:
  /// **'CONGRATULATIONS! 🎉'**
  String get congratulations;

  /// Good try message for losing
  ///
  /// In en, this message translates to:
  /// **'GOOD TRY! 🥲'**
  String get goodTry;

  /// Message showing how many songs were played
  ///
  /// In en, this message translates to:
  /// **'You completed the {rounds}-song series!'**
  String completedSeries(int rounds);

  /// Label for correct answers count
  ///
  /// In en, this message translates to:
  /// **'CORRECT'**
  String get correctLabel;

  /// Label for success rate percentage
  ///
  /// In en, this message translates to:
  /// **'SUCCESS'**
  String get successRateLabel;

  /// Label for XP earned
  ///
  /// In en, this message translates to:
  /// **'XP EARNED'**
  String get xpEarnedLabel;

  /// Title for the session summary section
  ///
  /// In en, this message translates to:
  /// **'SESSION SUMMARY'**
  String get sessionSummary;

  /// Label for return to modes button
  ///
  /// In en, this message translates to:
  /// **'Return to Modes'**
  String get returnToModes;

  /// Label for play again button
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Notification for correct guess
  ///
  /// In en, this message translates to:
  /// **'Correct Guess!'**
  String get correctGuess;

  /// Notification for wrong guess
  ///
  /// In en, this message translates to:
  /// **'Wrong Guess!'**
  String get wrongGuess;

  /// Subtitle on the home screen
  ///
  /// In en, this message translates to:
  /// **'Guess the song in 6 attempts'**
  String get subtitleTagline;

  /// Message shown when user tries to play daily challenge again
  ///
  /// In en, this message translates to:
  /// **'You have already played today\'s Daily Challenge. Come back tomorrow!'**
  String get dailyChallengePlayed;

  /// Label for the daily challenge button
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  /// Navigation label for modes tab
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get navModes;

  /// Navigation label for ranks tab
  ///
  /// In en, this message translates to:
  /// **'Ranks'**
  String get navRanks;

  /// Navigation label for stats tab
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// Navigation label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @modesTitle.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get modesTitle;

  /// No description provided for @gameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  /// No description provided for @modesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zero wait time. Pick a mode and play.'**
  String get modesSubtitle;

  /// No description provided for @unlimitedBadge.
  ///
  /// In en, this message translates to:
  /// **'UNLIMITED'**
  String get unlimitedBadge;

  /// No description provided for @noviceListener.
  ///
  /// In en, this message translates to:
  /// **'Novice Listener'**
  String get noviceListener;

  /// No description provided for @connectSpotifyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please connect your Spotify account in settings first.'**
  String get connectSpotifyFirst;

  /// No description provided for @myPlaylist.
  ///
  /// In en, this message translates to:
  /// **'From My Playlist'**
  String get myPlaylist;

  /// No description provided for @endlessMode.
  ///
  /// In en, this message translates to:
  /// **'Endless Mode'**
  String get endlessMode;

  /// No description provided for @fanTests.
  ///
  /// In en, this message translates to:
  /// **'Fan Tests'**
  String get fanTests;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @tenSongs.
  ///
  /// In en, this message translates to:
  /// **'10 SONGS'**
  String get tenSongs;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get filterTurkish;

  /// No description provided for @filterForeign.
  ///
  /// In en, this message translates to:
  /// **'Foreign'**
  String get filterForeign;

  /// No description provided for @filterNostalgia.
  ///
  /// In en, this message translates to:
  /// **'Nostalgic'**
  String get filterNostalgia;

  /// No description provided for @filterRap.
  ///
  /// In en, this message translates to:
  /// **'Rap'**
  String get filterRap;

  /// No description provided for @filterRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get filterRock;

  /// No description provided for @filterRb.
  ///
  /// In en, this message translates to:
  /// **'R&B'**
  String get filterRb;

  /// No description provided for @filterKpop.
  ///
  /// In en, this message translates to:
  /// **'K-Pop'**
  String get filterKpop;

  /// No description provided for @filterIndie.
  ///
  /// In en, this message translates to:
  /// **'Indie'**
  String get filterIndie;

  /// No description provided for @filterLatin.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get filterLatin;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @recordScore.
  ///
  /// In en, this message translates to:
  /// **'Record: {score}'**
  String recordScore(int score);

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @badgeGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get badgeGlobal;

  /// No description provided for @badgePopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get badgePopular;

  /// No description provided for @badgeNostalgia.
  ///
  /// In en, this message translates to:
  /// **'Nostalgia'**
  String get badgeNostalgia;

  /// No description provided for @fanTestTarkanTitle.
  ///
  /// In en, this message translates to:
  /// **'Tarkan'**
  String get fanTestTarkanTitle;

  /// No description provided for @fanTestTarkanDesc.
  ///
  /// In en, this message translates to:
  /// **'Guess the Megastar\'s 10 songs the fastest.'**
  String get fanTestTarkanDesc;

  /// No description provided for @fanTestSezenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sezen Aksu'**
  String get fanTestSezenTitle;

  /// No description provided for @fanTestSezenDesc.
  ///
  /// In en, this message translates to:
  /// **'Little Sparrow classics back to back.'**
  String get fanTestSezenDesc;

  /// No description provided for @fanTestMuslumTitle.
  ///
  /// In en, this message translates to:
  /// **'Müslüm Gürses'**
  String get fanTestMuslumTitle;

  /// No description provided for @fanTestMuslumDesc.
  ///
  /// In en, this message translates to:
  /// **'The father of Arabesque, the deepest 10 songs.'**
  String get fanTestMuslumDesc;

  /// No description provided for @fanTestManifestTitle.
  ///
  /// In en, this message translates to:
  /// **'Manifest'**
  String get fanTestManifestTitle;

  /// No description provided for @fanTestManifestDesc.
  ///
  /// In en, this message translates to:
  /// **'Turkish girl group hits: Snap, Amatör and more.'**
  String get fanTestManifestDesc;

  /// No description provided for @fanTestBlok3Title.
  ///
  /// In en, this message translates to:
  /// **'Blok3'**
  String get fanTestBlok3Title;

  /// No description provided for @fanTestBlok3Desc.
  ///
  /// In en, this message translates to:
  /// **'10 tracks that dominated the era. How many do you know?'**
  String get fanTestBlok3Desc;

  /// No description provided for @fanTestLvbelTitle.
  ///
  /// In en, this message translates to:
  /// **'Lvbel C5'**
  String get fanTestLvbelTitle;

  /// No description provided for @fanTestLvbelDesc.
  ///
  /// In en, this message translates to:
  /// **'Street music\'s hardest 10 tracks.'**
  String get fanTestLvbelDesc;

  /// No description provided for @fanTestCezaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ceza'**
  String get fanTestCezaTitle;

  /// No description provided for @fanTestCezaDesc.
  ///
  /// In en, this message translates to:
  /// **'The legend of Turkish rap. 10 classic tracks.'**
  String get fanTestCezaDesc;

  /// No description provided for @fanTestUziTitle.
  ///
  /// In en, this message translates to:
  /// **'Uzi'**
  String get fanTestUziTitle;

  /// No description provided for @fanTestUziDesc.
  ///
  /// In en, this message translates to:
  /// **'Pioneer of the trap scene. 10 tracks await you.'**
  String get fanTestUziDesc;

  /// No description provided for @genreTurkPopTitle.
  ///
  /// In en, this message translates to:
  /// **'Turkish Pop'**
  String get genreTurkPopTitle;

  /// No description provided for @genreTurkPopDesc.
  ///
  /// In en, this message translates to:
  /// **'Sezen Aksu, Tarkan, Gülşen, Kenan Doğulu...'**
  String get genreTurkPopDesc;

  /// No description provided for @genreTurkRapTitle.
  ///
  /// In en, this message translates to:
  /// **'Turkish Rap'**
  String get genreTurkRapTitle;

  /// No description provided for @genreTurkRapDesc.
  ///
  /// In en, this message translates to:
  /// **'Ezhel, Ceza, Sagopa Kajmer, Uzi, Motive...'**
  String get genreTurkRapDesc;

  /// No description provided for @genre2000PopTitle.
  ///
  /// In en, this message translates to:
  /// **'2000s Turkish Pop'**
  String get genre2000PopTitle;

  /// No description provided for @genre2000PopDesc.
  ///
  /// In en, this message translates to:
  /// **'Hepsi, Hande Yener, Demet Akalın, Serdar Ortaç'**
  String get genre2000PopDesc;

  /// No description provided for @genreGlobalPopTitle.
  ///
  /// In en, this message translates to:
  /// **'Global Pop'**
  String get genreGlobalPopTitle;

  /// No description provided for @genreGlobalPopDesc.
  ///
  /// In en, this message translates to:
  /// **'The Weeknd, Taylor Swift, Dua Lipa, Ed Sheeran'**
  String get genreGlobalPopDesc;

  /// No description provided for @genreRockTitle.
  ///
  /// In en, this message translates to:
  /// **'Rock Classics'**
  String get genreRockTitle;

  /// No description provided for @genreRockDesc.
  ///
  /// In en, this message translates to:
  /// **'Queen, AC/DC, Nirvana, The Rolling Stones'**
  String get genreRockDesc;

  /// No description provided for @genreRbTitle.
  ///
  /// In en, this message translates to:
  /// **'R&B / Soul'**
  String get genreRbTitle;

  /// No description provided for @genreRbDesc.
  ///
  /// In en, this message translates to:
  /// **'Bruno Mars, The Weeknd, Alicia Keys, Usher'**
  String get genreRbDesc;

  /// No description provided for @genreKpopTitle.
  ///
  /// In en, this message translates to:
  /// **'K-Pop'**
  String get genreKpopTitle;

  /// No description provided for @genreKpopDesc.
  ///
  /// In en, this message translates to:
  /// **'BTS, BLACKPINK, EXO, TWICE'**
  String get genreKpopDesc;

  /// No description provided for @genreIndieTitle.
  ///
  /// In en, this message translates to:
  /// **'Indie & Alternative'**
  String get genreIndieTitle;

  /// No description provided for @genreIndieDesc.
  ///
  /// In en, this message translates to:
  /// **'Arctic Monkeys, Tame Impala, The Strokes'**
  String get genreIndieDesc;

  /// No description provided for @genreLatinTitle.
  ///
  /// In en, this message translates to:
  /// **'Latin Hits'**
  String get genreLatinTitle;

  /// No description provided for @genreLatinDesc.
  ///
  /// In en, this message translates to:
  /// **'Bad Bunny, J Balvin, Shakira, Rosalía'**
  String get genreLatinDesc;

  /// No description provided for @leaderboardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboardsTitle;

  /// No description provided for @leaderboardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete daily, earn bragging rights & badges'**
  String get leaderboardsSubtitle;

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet.'**
  String get noPlayersYet;

  /// No description provided for @failedToLoadRanks.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ranks:\n{error}'**
  String failedToLoadRanks(String error);

  /// No description provided for @soundDeity.
  ///
  /// In en, this message translates to:
  /// **'SOUND DEITY'**
  String get soundDeity;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get points;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get average;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @youRankText.
  ///
  /// In en, this message translates to:
  /// **'You ({name})'**
  String youRankText(String name);

  /// No description provided for @vipBadge.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vipBadge;

  /// No description provided for @topFivePercent.
  ///
  /// In en, this message translates to:
  /// **'Top 5%'**
  String get topFivePercent;

  /// No description provided for @compareBtn.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get compareBtn;

  /// No description provided for @rankAndPlayer.
  ///
  /// In en, this message translates to:
  /// **'RANK & PLAYER'**
  String get rankAndPlayer;

  /// No description provided for @pointsAndStreak.
  ///
  /// In en, this message translates to:
  /// **'POINTS / STREAK'**
  String get pointsAndStreak;

  /// No description provided for @avgAndDailyText.
  ///
  /// In en, this message translates to:
  /// **'Avg {avg} • Daily #184: 1st Guess'**
  String avgAndDailyText(String avg);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @resetAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllDataTitle;

  /// No description provided for @resetAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your stats and progress? This cannot be undone.'**
  String get resetAllDataDesc;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @dataResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been reset.'**
  String get dataResetSuccess;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get turkish;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @resetAllDataBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllDataBtn;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get connectedAccounts;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @tapToConnect.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect'**
  String get tapToConnect;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @spotifyConnected.
  ///
  /// In en, this message translates to:
  /// **'Spotify connected successfully!'**
  String get spotifyConnected;

  /// No description provided for @spotifyConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get spotifyConnectionFailed;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @novice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get novice;

  /// No description provided for @risingStar.
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get risingStar;

  /// No description provided for @soundMaestro.
  ///
  /// In en, this message translates to:
  /// **'Sound Maestro'**
  String get soundMaestro;

  /// No description provided for @musicDeity.
  ///
  /// In en, this message translates to:
  /// **'Music Deity'**
  String get musicDeity;

  /// No description provided for @lvlText.
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String lvlText(int level);

  /// No description provided for @levelProgressText.
  ///
  /// In en, this message translates to:
  /// **'Level {current} → Level {next}'**
  String levelProgressText(int current, int next);

  /// No description provided for @xpProgressText.
  ///
  /// In en, this message translates to:
  /// **'{current} / {next} XP'**
  String xpProgressText(int current, int next);

  /// No description provided for @xpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to Level {level}'**
  String xpToNextLevel(int xp, int level);

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total: {xp} XP'**
  String totalXp(int xp);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @totalPlayed.
  ///
  /// In en, this message translates to:
  /// **'Total Played'**
  String get totalPlayed;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @solvedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Solved'**
  String solvedCount(int count);

  /// No description provided for @currentStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreakTitle;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active Days'**
  String get activeDays;

  /// No description provided for @bestStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreakTitle;

  /// No description provided for @allTimeHigh.
  ///
  /// In en, this message translates to:
  /// **'All Time High'**
  String get allTimeHigh;

  /// No description provided for @guessDistribution.
  ///
  /// In en, this message translates to:
  /// **'Guess Distribution'**
  String get guessDistribution;

  /// No description provided for @guessDistributionDesc.
  ///
  /// In en, this message translates to:
  /// **'Frequency by snippet duration'**
  String get guessDistributionDesc;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @peak.
  ///
  /// In en, this message translates to:
  /// **'(Peak)'**
  String get peak;

  /// No description provided for @genreDna.
  ///
  /// In en, this message translates to:
  /// **'Genre DNA'**
  String get genreDna;

  /// No description provided for @genreDnaDesc.
  ///
  /// In en, this message translates to:
  /// **'Ear calibration by musical territory'**
  String get genreDnaDesc;

  /// No description provided for @diamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get diamond;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @lastSolvedVictory.
  ///
  /// In en, this message translates to:
  /// **'Last Solved Victory'**
  String get lastSolvedVictory;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @editProfileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileDialogTitle;

  /// No description provided for @editProfileDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your display name for the leaderboards.'**
  String get editProfileDialogDesc;

  /// No description provided for @newNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your new name...'**
  String get newNameHint;

  /// No description provided for @nameUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your name has been updated successfully!'**
  String get nameUpdatedSuccess;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @fanTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Fan Test: {name}'**
  String fanTestTitle(String name);

  /// No description provided for @dailyBadgeText.
  ///
  /// In en, this message translates to:
  /// **'DAILY #{number}'**
  String dailyBadgeText(int number);

  /// No description provided for @snippetDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} snippet'**
  String snippetDuration(String duration);

  /// No description provided for @guessCountText.
  ///
  /// In en, this message translates to:
  /// **'Guess {current}/{max}'**
  String guessCountText(int current, int max);

  /// No description provided for @correctlyGuessed.
  ///
  /// In en, this message translates to:
  /// **'Correctly Guessed'**
  String get correctlyGuessed;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @wronglyGuessed.
  ///
  /// In en, this message translates to:
  /// **'Wrongly Guessed'**
  String get wronglyGuessed;

  /// No description provided for @skipAction.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipAction;

  /// No description provided for @genreHintUnlockedAt.
  ///
  /// In en, this message translates to:
  /// **'Genre hint unlocked at 4.0s'**
  String get genreHintUnlockedAt;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play '**
  String get howToPlay;

  /// No description provided for @snippetProgression.
  ///
  /// In en, this message translates to:
  /// **'SNIPPET PROGRESSION'**
  String get snippetProgression;

  /// No description provided for @stageProgression.
  ///
  /// In en, this message translates to:
  /// **'Stage {current} of {total}'**
  String stageProgression(int current, int total);

  /// No description provided for @statisticsUpper.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statisticsUpper;

  /// No description provided for @playedLabel.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get playedLabel;

  /// No description provided for @winPercentageLabel.
  ///
  /// In en, this message translates to:
  /// **'Win %'**
  String get winPercentageLabel;

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current\nStreak'**
  String get currentStreakLabel;

  /// No description provided for @maxStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Max\nStreak'**
  String get maxStreakLabel;

  /// No description provided for @spotifyPlaylistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Spotify Playlists'**
  String get spotifyPlaylistsTitle;

  /// No description provided for @noPlaylistsFound.
  ///
  /// In en, this message translates to:
  /// **'No playlists found.'**
  String get noPlaylistsFound;

  /// No description provided for @unknownPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Unknown Playlist'**
  String get unknownPlaylist;

  /// No description provided for @songCountText.
  ///
  /// In en, this message translates to:
  /// **'{count} Songs'**
  String songCountText(int count);

  /// No description provided for @songsLabel.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsLabel;

  /// No description provided for @emojiModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Emoji Mode'**
  String get emojiModeTitle;

  /// No description provided for @stageUnlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Stage'**
  String get stageUnlockDialogTitle;

  /// No description provided for @stageUnlockDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'You need 200 MeloCoins to unlock Stage {stage}.'**
  String stageUnlockDialogDesc(int stage);

  /// No description provided for @payCoinButton.
  ///
  /// In en, this message translates to:
  /// **'Pay 200 Coins'**
  String get payCoinButton;

  /// No description provided for @notEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins!'**
  String get notEnoughCoins;

  /// No description provided for @emojiStageCompleted.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You completed the stage! 🏆'**
  String get emojiStageCompleted;

  /// No description provided for @emojiAllStagesCompleted.
  ///
  /// In en, this message translates to:
  /// **'YOU BEAT THE GAME! BIG REWARD COMING SOON! 👑'**
  String get emojiAllStagesCompleted;

  /// No description provided for @stageAndQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage} • Question {question}/10'**
  String stageAndQuestionProgress(int stage, int question);

  /// No description provided for @wrongGuessLabel.
  ///
  /// In en, this message translates to:
  /// **'Wrong Guess: {guess}'**
  String wrongGuessLabel(String guess);

  /// No description provided for @artistLabel.
  ///
  /// In en, this message translates to:
  /// **'Artist: {artist}'**
  String artistLabel(String artist);

  /// No description provided for @jokersTitle.
  ///
  /// In en, this message translates to:
  /// **'Jokers'**
  String get jokersTitle;

  /// No description provided for @revealLetter.
  ///
  /// In en, this message translates to:
  /// **'Reveal Letter'**
  String get revealLetter;

  /// No description provided for @revealArtist.
  ///
  /// In en, this message translates to:
  /// **'Reveal Artist'**
  String get revealArtist;

  /// No description provided for @giveUpAndSkip.
  ///
  /// In en, this message translates to:
  /// **'Give Up & Skip'**
  String get giveUpAndSkip;

  /// No description provided for @stageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stage {stage}'**
  String stageTitle(int stage);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
