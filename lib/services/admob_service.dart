
// import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static String get interstitialAdUnitId => 'ca-app-pub-9133183118664083/7252895988';

  InterstitialAd? _interstitialAd;

  void loadInterstitialAd({bool isPremium = false}) {
    if (isPremium) {
      if (_interstitialAd != null) {
        _interstitialAd!.dispose();
        _interstitialAd = null;
      }
      return;
    }

    if (_interstitialAd != null) return;

    print("AdmobService: Loading interstitial ad.");
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print("AdmobService: Interstitial ad loaded successfully.");
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          print("AdmobService: Interstitial ad failed to load: $err");
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({bool isPremium = false}) {
    if (isPremium) {
      print("AdmobService: Premium user, not showing ad.");
      return;
    }

    if (_interstitialAd != null) {
      print("AdmobService: Showing interstitial ad.");
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print("AdmobService: Interstitial ad dismissed.");
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Pre-load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          print("AdmobService: Interstitial ad failed to show: $err");
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Pre-load next ad
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print("AdmobService: Interstitial ad not ready.");
      loadInterstitialAd(); // Load an ad to be ready for the next time.
    }
  }
}
