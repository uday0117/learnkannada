import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'monetization_service.dart';

/// Centralized service for Google Mobile Ads (AdMob)
///
/// Configured Ad Units:
/// - Home Banner: learn_kannada_home_banner (ca-app-pub-1451522103593938/7708609710)
/// - Quiz Interstitial: learn_kannada_quiz_interstitial (ca-app-pub-1451522103593938/2755665931)
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _quizInterstitialAd;
  bool _isInterstitialLoading = false;

  /// In debug mode, Google AdMob requires test ad units to avoid policy violations.
  /// When false in debug mode, standard Google test ad units are used.
  /// In release mode, production ad units are ALWAYS served.
  static bool forceLiveAds = false;

  // Production Ad Units provided by the user
  static const String prodHomeBannerId =
      'ca-app-pub-1451522103593938/7708609710';
  static const String prodQuizInterstitialId =
      'ca-app-pub-1451522103593938/2755665931';

  // Standard Google AdMob Test Ad Units
  static const String testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  static const String testAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  /// Returns whether test ads should be served
  bool get shouldUseTestAds => kDebugMode && !forceLiveAds;

  /// Effective Banner Ad Unit ID
  String get homeBannerAdUnitId {
    if (shouldUseTestAds) {
      return Platform.isIOS ? testIosBannerId : testAndroidBannerId;
    }
    return prodHomeBannerId;
  }

  /// Effective Quiz Interstitial Ad Unit ID
  String get quizInterstitialAdUnitId {
    if (shouldUseTestAds) {
      return Platform.isIOS ? testIosInterstitialId : testAndroidInterstitialId;
    }
    return prodQuizInterstitialId;
  }

  /// Initialize MobileAds SDK
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final status = await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdService: MobileAds initialized: ${status.adapterStatuses}');
      // Pre-load the quiz interstitial ad so it is ready when quiz completes
      loadQuizInterstitial();
    } catch (e) {
      debugPrint('AdService: Failed to initialize MobileAds: $e');
    }
  }

  /// Preload the Quiz Interstitial Ad
  void loadQuizInterstitial() {
    if (MonetizationService().isPremium) return;
    if (!_isInitialized || _isInterstitialLoading || _quizInterstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    final adUnitId = quizInterstitialAdUnitId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialLoading = false;
          _quizInterstitialAd = ad;
          debugPrint('AdService: Quiz Interstitial loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _quizInterstitialAd = null;
          debugPrint('AdService: Quiz Interstitial failed to load: ${error.message} (Code: ${error.code})');
          // Fallback to official Google test unit if prod failed in testing
          if (adUnitId != (Platform.isIOS ? testIosInterstitialId : testAndroidInterstitialId)) {
            final fallbackId = Platform.isIOS ? testIosInterstitialId : testAndroidInterstitialId;
            InterstitialAd.load(
              adUnitId: fallbackId,
              request: const AdRequest(),
              adLoadCallback: InterstitialAdLoadCallback(
                onAdLoaded: (fallbackAd) {
                  _quizInterstitialAd = fallbackAd;
                  debugPrint('AdService: Fallback test interstitial loaded successfully.');
                },
                onAdFailedToLoad: (fallbackErr) {
                  debugPrint('AdService: Fallback interstitial failed: ${fallbackErr.message}');
                },
              ),
            );
          }
        },
      ),
    );
  }

  /// Show the preloaded Quiz Interstitial Ad.
  /// If not ready or user is premium, immediately executes [onDismissed] to never block user flow.
  Future<void> showQuizInterstitial({VoidCallback? onDismissed}) async {
    if (MonetizationService().isPremium ||
        !MonetizationService().shouldShowQuizInterstitial()) {
      onDismissed?.call();
      return;
    }

    // If ad is actively loading, wait up to 1200ms for it to finish loading
    if (_quizInterstitialAd == null && _isInterstitialLoading) {
      int waited = 0;
      while (_isInterstitialLoading && _quizInterstitialAd == null && waited < 1200) {
        await Future.delayed(const Duration(milliseconds: 150));
        waited += 150;
      }
    }

    final ad = _quizInterstitialAd;
    if (ad == null) {
      debugPrint('AdService: Interstitial not ready yet, proceeding directly.');
      onDismissed?.call();
      loadQuizInterstitial(); // Try loading again for next time
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: Interstitial displayed full screen.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: Interstitial dismissed by user.');
        ad.dispose();
        _quizInterstitialAd = null;
        onDismissed?.call();
        // Pre-load for next quiz attempt
        loadQuizInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: Interstitial failed to show: ${error.message}');
        ad.dispose();
        _quizInterstitialAd = null;
        onDismissed?.call();
        loadQuizInterstitial();
      },
    );

    ad.show();
  }

  /// Dispose cached ads on shutdown
  void dispose() {
    _quizInterstitialAd?.dispose();
    _quizInterstitialAd = null;
  }
}
