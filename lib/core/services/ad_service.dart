import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  int _numInterstitialLoadAttempts = 0;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  int _interstitialCounter = 0;

  bool get isRewardedAdLoaded => _rewardedAd != null;
  bool get isInterstitialAdLoaded => _interstitialAd != null;
  bool get isAdLoaded => isRewardedAdLoaded;

  void loadRewardedAd() => createRewardedAd();
  void loadInterstitialAd() => createInterstitialAd();

  void createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('$ad loaded');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  /// Shows an interstitial ad only every [frequency] calls to prevent annoying the user.
  void showInterstitialAdWithFrequency({
    int frequency = 2,
    VoidCallback? onAdDismissed,
  }) {
    _interstitialCounter++;
    if (_interstitialCounter % frequency == 0) {
      showInterstitialAd(onAdDismissed: onAdDismissed);
    } else {
      if (onAdDismissed != null) {
        onAdDismissed();
      }
    }
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      createInterstitialAd();
      if (onAdDismissed != null) {
        onAdDismissed();
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
        if (onAdDismissed != null) {
          onAdDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
        if (onAdDismissed != null) {
          onAdDismissed();
        }
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void createRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onUserEarnedReward,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      createRewardedAd();
      if (onAdFailed != null) {
        onAdFailed();
      }
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewardedAd();
        if (onAdDismissed != null) {
          onAdDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd();
        if (onAdFailed != null) {
          onAdFailed();
        }
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      if (onUserEarnedReward is void Function(RewardItem)) {
        onUserEarnedReward(reward);
      } else {
        onUserEarnedReward();
      }
    });
    _rewardedAd = null;
  }
}
