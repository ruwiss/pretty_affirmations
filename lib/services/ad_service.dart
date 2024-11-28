import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'GERÇEK_BANNER_ID';
  final String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'GERÇEK_INTERSTITIAL_ID';
  final String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'GERÇEK_REWARDED_ID';
  final String _nativeAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'GERÇEK_NATIVE_ID';
  final String _appOpenAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-1923752572867502/7608509858';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  NativeAd? _nativeAd;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAppOpenAdAvailable = false;

  Future<void> loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner reklam yüklendi.'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner reklam yüklenemedi: $error');
        },
      ),
    );
    return _bannerAd!.load();
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Geçiş reklamı yüklendi.');
        },
        onAdFailedToLoad: (error) =>
            debugPrint('Geçiş reklamı yüklenemedi: $error'),
      ),
    );
  }

  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('Ödüllü reklam yüklendi.');
        },
        onAdFailedToLoad: (error) =>
            debugPrint('Ödüllü reklam yüklenemedi: $error'),
      ),
    );
  }

  Future<void> loadNativeAd() async {
    _nativeAd = NativeAd(
      adUnitId: _nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => debugPrint('Native reklam yüklendi.'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Native reklam yüklenemedi: $error');
        },
      ),
    );
    return _nativeAd!.load();
  }

  Future<void> loadAppOpenAd() async {
    await AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdAvailable = true;
          debugPrint('App Open reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          _isAppOpenAdAvailable = false;
          debugPrint('App Open reklam yüklenemedi: $error');
        },
      ),
    );
  }

  Widget showBannerAd() {
    if (_bannerAd == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
        },
      );
      await _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<void> showRewardedAd() async {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
      await _rewardedAd!.show(onUserEarnedReward: (_, reward) {
        debugPrint('Kullanıcı ${reward.amount} ${reward.type} kazandı.');
      });
      _rewardedAd = null;
    }
  }

  Widget showNativeAd() {
    if (_nativeAd == null) return const SizedBox.shrink();
    return Container(
      height: 72.0,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }

  void showAppOpenAd() {
    if (!_isAppOpenAdAvailable) return;
    if (_isShowingAd) return;
    if (_appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('App Open reklam gösterildi.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open reklam gösterilemedi: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open reklam kapatıldı.');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  void handleAppStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showAppOpenAd();
    } else if (state == AppLifecycleState.paused) {
      loadAppOpenAd();
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _nativeAd?.dispose();
    _appOpenAd?.dispose();
  }
}
