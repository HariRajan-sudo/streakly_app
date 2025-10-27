
// import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobService {
  static String get interstitialAdUnitId => 'ca-app-pub-9133183118664083/7252895988';

  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
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

  void showInterstitialAd() {
      if (_interstitialAd != null) {
        print("AdmobService: Showing interstitial ad.");
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            print("AdmobService: Interstitial ad dismissed.");
            ad.dispose();
            loadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            print("AdmobService: Interstitial ad failed to show: $err");
            ad.dispose();
            loadInterstitialAd();
          },
        );
        _interstitialAd!.show();
        _interstitialAd = null;
      } else {
        print("AdmobService: Interstitial ad not ready.");
        loadInterstitialAd();
      }
    }
}
