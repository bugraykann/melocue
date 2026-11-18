// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Melocue';

  @override
  String get playButton => 'Oyna';

  @override
  String skipButton(int seconds) {
    return 'Geç (+${seconds}sn)';
  }

  @override
  String get loopButton => 'Tekrarla';

  @override
  String get guessInputPlaceholder => 'Şarkı veya sanatçı adını tahmin et...';

  @override
  String get submitButton => 'Gönder';

  @override
  String get congratulations => 'TEBRİKLER! 🎉';

  @override
  String get goodTry => 'İYİ DENEME! 🥲';

  @override
  String completedSeries(int rounds) {
    return '$rounds Şarkılık Seriyi Tamamladın!';
  }

  @override
  String get correctLabel => 'DOĞRU';

  @override
  String get successRateLabel => 'BAŞARI';

  @override
  String get xpEarnedLabel => 'XP KAZANILDI';

  @override
  String get sessionSummary => 'SEANS ÖZETİ';

  @override
  String get returnToModes => 'Modlara Dön';

  @override
  String get playAgain => 'Tekrar Oyna';

  @override
  String get correctGuess => 'Doğru Tahmin!';

  @override
  String get wrongGuess => 'Yanlış Tahmin!';

  @override
  String get subtitleTagline => 'Şarkıyı 6 denemede bul';

  @override
  String get dailyChallengePlayed =>
      'Bugünkü Günlük Görevi zaten oynadın. Yarın tekrar gel!';

  @override
  String get dailyChallenge => 'Günlük Görev';

  @override
  String get navModes => 'Modlar';

  @override
  String get navRanks => 'Rütbeler';

  @override
  String get navStats => 'İstatistik';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get modesTitle => 'Modlar';

  @override
  String get gameModes => 'Oyun Modları';

  @override
  String get modesSubtitle => 'Sıfır bekleme süresi. Modunu seç, başla.';

  @override
  String get unlimitedBadge => 'SINIRSIZ';

  @override
  String get noviceListener => 'Acemi Dinleyici';

  @override
  String get connectSpotifyFirst =>
      'Önce ayarlardan Spotify hesabınızı bağlayın.';

  @override
  String get myPlaylist => 'Kendi Listemden';

  @override
  String get endlessMode => 'Sonsuz Mod';

  @override
  String get fanTests => 'Fan Testleri';

  @override
  String get popular => 'Popüler';

  @override
  String get tenSongs => '10 ŞARKI';

  @override
  String get categories => 'Kategoriler';

  @override
  String get all => 'Hepsi';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterTurkish => 'Türkçe';

  @override
  String get filterForeign => 'Yabancı';

  @override
  String get filterNostalgia => 'Nostalji';

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
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String recordScore(int score) {
    return 'Rekor: $score';
  }

  @override
  String get badgeNew => 'Yeni';

  @override
  String get badgeGlobal => 'Global';

  @override
  String get badgePopular => 'Popüler';

  @override
  String get badgeNostalgia => 'Nostalji';

  @override
  String get fanTestTarkanTitle => 'Tarkan';

  @override
  String get fanTestTarkanDesc => 'Megastar\'ın 10 şarkısını en hızlı sen bil.';

  @override
  String get fanTestSezenTitle => 'Sezen Aksu';

  @override
  String get fanTestSezenDesc => 'Minik Serçe klasikleri arka arkaya.';

  @override
  String get fanTestMuslumTitle => 'Müslüm Gürses';

  @override
  String get fanTestMuslumDesc => 'Arabeskin babası, en damar 10 şarkı.';

  @override
  String get fanTestManifestTitle => 'Manifest';

  @override
  String get fanTestManifestDesc =>
      'Türk kız grubunun hit\'leri: Snap, Amatör ve daha fazlası.';

  @override
  String get fanTestBlok3Title => 'Blok3';

  @override
  String get fanTestBlok3Desc =>
      'Dönemi domine eden 10 parça. Kaçını bilirsin?';

  @override
  String get fanTestLvbelTitle => 'Lvbel C5';

  @override
  String get fanTestLvbelDesc => 'Sokak müziğinin en sert 10 şarkısı.';

  @override
  String get fanTestCezaTitle => 'Ceza';

  @override
  String get fanTestCezaDesc => 'Türkçe rap efsanesi. 10 klasik şarkı.';

  @override
  String get fanTestUziTitle => 'Uzi';

  @override
  String get fanTestUziDesc =>
      'Trap sahnesinin öncüsü. 10 şarkı seni bekliyor.';

  @override
  String get genreTurkPopTitle => 'Türkçe Pop';

  @override
  String get genreTurkPopDesc => 'Sezen Aksu, Tarkan, Gülşen, Kenan Doğulu...';

  @override
  String get genreTurkRapTitle => 'Türkçe Rap';

  @override
  String get genreTurkRapDesc => 'Ezhel, Ceza, Sagopa Kajmer, Uzi, Motive...';

  @override
  String get genre2000PopTitle => '2000\'ler Türkçe Pop';

  @override
  String get genre2000PopDesc =>
      'Hepsi, Hande Yener, Demet Akalın, Serdar Ortaç';

  @override
  String get genreGlobalPopTitle => 'Yabancı Pop';

  @override
  String get genreGlobalPopDesc =>
      'The Weeknd, Taylor Swift, Dua Lipa, Ed Sheeran';

  @override
  String get genreRockTitle => 'Rock Klasikleri';

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
  String get genreIndieTitle => 'Indie & Alternatif';

  @override
  String get genreIndieDesc => 'Arctic Monkeys, Tame Impala, The Strokes';

  @override
  String get genreLatinTitle => 'Latin Hitleri';

  @override
  String get genreLatinDesc => 'Bad Bunny, J Balvin, Shakira, Rosalía';

  @override
  String get leaderboardsTitle => 'Lider Tablosu';

  @override
  String get leaderboardsSubtitle => 'Her gün yarış, rozetleri kap.';

  @override
  String get noPlayersYet => 'Henüz oyuncu yok.';

  @override
  String failedToLoadRanks(String error) {
    return 'Rütbeler yüklenemedi:\n$error';
  }

  @override
  String get soundDeity => 'MÜZİK İLAHI';

  @override
  String get points => 'puan';

  @override
  String get average => 'ort';

  @override
  String get streak => 'Seri';

  @override
  String youRankText(String name) {
    return 'Sen ($name)';
  }

  @override
  String get vipBadge => 'VIP';

  @override
  String get topFivePercent => 'İlk %5';

  @override
  String get compareBtn => 'Karşılaştır';

  @override
  String get rankAndPlayer => 'RÜTBE & OYUNCU';

  @override
  String get pointsAndStreak => 'PUAN / SERİ';

  @override
  String avgAndDailyText(String avg) {
    return 'Ort $avg • Günlük #184: 1. Tahmin';
  }

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get resetAllDataTitle => 'Tüm Verileri Sıfırla';

  @override
  String get resetAllDataDesc =>
      'Tüm istatistiklerinizi ve ilerlemenizi sıfırlamak istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get cancel => 'İptal';

  @override
  String get reset => 'Sıfırla';

  @override
  String get dataResetSuccess => 'Tüm veriler sıfırlandı.';

  @override
  String get preferences => 'Tercihler';

  @override
  String get language => 'Dil';

  @override
  String get turkish => 'Türkçe';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get haptics => 'Titreşim';

  @override
  String get dataAndPrivacy => 'Veri & Gizlilik';

  @override
  String get resetAllDataBtn => 'Tüm Verileri Sıfırla';

  @override
  String get connectedAccounts => 'Bağlı Hesaplar';

  @override
  String get connected => 'Bağlandı';

  @override
  String get tapToConnect => 'Bağlanmak için dokun';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get spotifyConnected => 'Spotify başarıyla bağlandı!';

  @override
  String get spotifyConnectionFailed => 'Bağlantı başarısız oldu.';

  @override
  String get about => 'Hakkında';

  @override
  String get version => 'Versiyon';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get player => 'Oyuncu';

  @override
  String get novice => 'Çaylak';

  @override
  String get risingStar => 'Yükselen Yıldız';

  @override
  String get soundMaestro => 'Ses Maestrosu';

  @override
  String get musicDeity => 'Müzik İlahı';

  @override
  String lvlText(int level) {
    return 'Svy $level';
  }

  @override
  String levelProgressText(int current, int next) {
    return 'Seviye $current → Seviye $next';
  }

  @override
  String xpProgressText(int current, int next) {
    return '$current / $next XP';
  }

  @override
  String xpToNextLevel(int xp, int level) {
    return 'Seviye $level için $xp XP';
  }

  @override
  String totalXp(int xp) {
    return 'Toplam: $xp XP';
  }

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get challenges => 'Mücadeleler';

  @override
  String get totalPlayed => 'Toplam Oynanan';

  @override
  String get winRate => 'Kazanma Oranı';

  @override
  String solvedCount(int count) {
    return '$count Çözüldü';
  }

  @override
  String get currentStreakTitle => 'Mevcut Seri';

  @override
  String get days => 'Gün';

  @override
  String get activeDays => 'Aktif Gün';

  @override
  String get bestStreakTitle => 'En İyi Seri';

  @override
  String get allTimeHigh => 'Tüm Zamanların En İyisi';

  @override
  String get guessDistribution => 'Tahmin Dağılımı';

  @override
  String get guessDistributionDesc => 'Klip süresine göre sıklık';

  @override
  String get fail => 'Başarısız';

  @override
  String get peak => '(Zirve)';

  @override
  String get genreDna => 'Müzik Türü DNA';

  @override
  String get genreDnaDesc => 'Müzikal bölgeye göre kulak kalibrasyonu';

  @override
  String get diamond => 'Elmas';

  @override
  String get gold => 'Altın';

  @override
  String get silver => 'Gümüş';

  @override
  String get bronze => 'Bronz';

  @override
  String get lastSolvedVictory => 'Son Çözülen';

  @override
  String get recent => 'Yakın Zaman';

  @override
  String get editProfileDialogTitle => 'Profilini Düzenle';

  @override
  String get editProfileDialogDesc =>
      'Liderlik tablosunda görünecek ismini belirle.';

  @override
  String get newNameHint => 'Yeni isminiz...';

  @override
  String get nameUpdatedSuccess => 'İsminiz başarıyla güncellendi!';

  @override
  String get save => 'Kaydet';

  @override
  String get category => 'Kategori';

  @override
  String fanTestTitle(String name) {
    return 'Fan Testi: $name';
  }

  @override
  String dailyBadgeText(int number) {
    return 'GÜNLÜK #$number';
  }

  @override
  String snippetDuration(String duration) {
    return '$duration klip';
  }

  @override
  String guessCountText(int current, int max) {
    return 'Tahmin $current/$max';
  }

  @override
  String get correctlyGuessed => 'Doğru Bildin';

  @override
  String get skipped => 'Pas Geçildi';

  @override
  String get wronglyGuessed => 'Yanlış Bilindi';

  @override
  String get skipAction => 'Pas Geç';

  @override
  String get genreHintUnlockedAt => 'Müzik türü ipucu 4.0s\'de açılır';

  @override
  String get howToPlay => 'Nasıl oynanır ';

  @override
  String get snippetProgression => 'KLİP İLERLEMESİ';

  @override
  String stageProgression(int current, int total) {
    return 'Aşama $current / $total';
  }

  @override
  String get statisticsUpper => 'İSTATİSTİKLER';

  @override
  String get playedLabel => 'Oynanan';

  @override
  String get winPercentageLabel => 'Kazanma %';

  @override
  String get currentStreakLabel => 'Mevcut\nSeri';

  @override
  String get maxStreakLabel => 'En İyi\nSeri';

  @override
  String get spotifyPlaylistsTitle => 'Spotify Çalma Listelerin';

  @override
  String get noPlaylistsFound => 'Çalma listeniz bulunmuyor.';

  @override
  String get unknownPlaylist => 'Bilinmeyen Liste';

  @override
  String songCountText(int count) {
    return '$count Şarkı';
  }

  @override
  String get songsLabel => 'Şarkılar';

  @override
  String get emojiModeTitle => 'Emoji Modu';

  @override
  String get stageUnlockDialogTitle => 'Aşamayı Aç';

  @override
  String stageUnlockDialogDesc(int stage) {
    return 'Aşama $stage\'i açmak için 200 MeloCoin gerekiyor.';
  }

  @override
  String get payCoinButton => '200 Coin Öde';

  @override
  String get notEnoughCoins => 'Yetersiz Coin!';

  @override
  String get emojiStageCompleted => 'Tebrikler! Aşamayı Tamamladın! 🏆';

  @override
  String get emojiAllStagesCompleted =>
      'TÜM OYUNU BİTİRDİN! BÜYÜK ÖDÜL YAKINDA! 👑';

  @override
  String stageAndQuestionProgress(int stage, int question) {
    return 'Aşama $stage • Soru $question/10';
  }

  @override
  String wrongGuessLabel(String guess) {
    return 'Yanlış Tahmin: $guess';
  }

  @override
  String artistLabel(String artist) {
    return 'Sanatçı: $artist';
  }

  @override
  String get jokersTitle => 'Jokerler';

  @override
  String get revealLetter => 'Harf Aç';

  @override
  String get revealArtist => 'Sanatçıyı Göster';

  @override
  String get giveUpAndSkip => 'Pes Et & Atla';

  @override
  String stageTitle(int stage) {
    return 'Aşama $stage';
  }
}
