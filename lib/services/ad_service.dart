import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reklam yükleme durumlarını takip etmek için enum
enum AdLoadState { initial, loading, loaded, error, shown }

/// Reklam kimliklerini tutmak için model
class AdIds {
  final String bannerId;
  final String interstitialId;
  final String rewardedId;
  final String nativeId;
  final String appOpenId;

  const AdIds({
    required this.bannerId,
    required this.interstitialId,
    required this.rewardedId,
    required this.nativeId,
    required this.appOpenId,
  });

  /// Test reklamları için factory constructor
  factory AdIds.test() => const AdIds(
        bannerId: 'ca-app-pub-3940256099942544/6300978111',
        interstitialId: 'ca-app-pub-3940256099942544/1033173712',
        rewardedId: 'ca-app-pub-3940256099942544/5224354917',
        nativeId: 'ca-app-pub-3940256099942544/2247696110',
        appOpenId: 'ca-app-pub-3940256099942544/9257395921',
      );
}

/// Reklam servisinin konfigürasyonu için model
class AdConfig {
  final AdIds adIds;
  final Duration minLoadAttemptDelay;
  final int maxFailedLoadAttempts;
  final bool enableTestMode;

  const AdConfig({
    required this.adIds,
    this.minLoadAttemptDelay = const Duration(seconds: 1),
    this.maxFailedLoadAttempts = 3,
    this.enableTestMode = false,
  });
}

/// Reklam durumlarını dinlemek için callback'ler
class AdCallbacks {
  final VoidCallback? onAdLoaded;
  final Function(AdError)? onAdFailedToLoad;
  final VoidCallback? onAdShown;
  final VoidCallback? onAdDismissed;
  final Function(RewardItem)? onUserEarnedReward;

  const AdCallbacks({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdShown,
    this.onAdDismissed,
    this.onUserEarnedReward,
  });
}

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  late final AdConfig _config;

  // Reklam durumlarını tutacak değişkenler
  AdLoadState _bannerState = AdLoadState.initial;
  AdLoadState _interstitialState = AdLoadState.initial;
  AdLoadState _rewardedState = AdLoadState.initial;
  AdLoadState _nativeState = AdLoadState.initial;
  AdLoadState _appOpenState = AdLoadState.initial;

  // Reklam instance'ları
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  NativeAd? _nativeAd;
  AppOpenAd? _appOpenAd;

  // Durum değişkenleri
  bool _isShowingAd = false;
  bool _isAppOpenAdAvailable = false;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;
  DateTime? _lastInterstitialShowTime;
  bool _isInitialized = false;

  /// Servisi başlatmak için init metodu
  void init(AdConfig config) {
    if (_isInitialized) return;
    _config = config;
    _isInitialized = true;
    // Sadece AppOpen reklamını yükle
    loadAppOpenAd();
  }

  /// Banner reklam yükleme
  Future<void> loadBannerAd({AdCallbacks? callbacks}) async {
    if (_bannerState == AdLoadState.loading) return;
    _bannerState = AdLoadState.loading;

    _bannerAd = BannerAd(
      adUnitId: _config.adIds.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerState = AdLoadState.loaded;
          callbacks?.onAdLoaded?.call();
          debugPrint('Banner reklam yüklendi.');
        },
        onAdFailedToLoad: (ad, error) {
          _bannerState = AdLoadState.error;
          ad.dispose();
          callbacks?.onAdFailedToLoad?.call(error);
          debugPrint('Banner reklam yüklenemedi: $error');
        },
      ),
    );
    return _bannerAd!.load();
  }

  /// Geçiş reklamı yükleme
  Future<void> loadInterstitialAd({AdCallbacks? callbacks}) async {
    if (_interstitialState == AdLoadState.loading) return;
    if (_interstitialLoadAttempts >= _config.maxFailedLoadAttempts) return;

    _interstitialState = AdLoadState.loading;

    await InterstitialAd.load(
      adUnitId: _config.adIds.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialState = AdLoadState.loaded;
          _interstitialLoadAttempts = 0;
          callbacks?.onAdLoaded?.call();
          debugPrint('Geçiş reklamı yüklendi.');
        },
        onAdFailedToLoad: (error) {
          _interstitialState = AdLoadState.error;
          _interstitialLoadAttempts++;
          callbacks?.onAdFailedToLoad?.call(error);
          debugPrint('Geçiş reklamı yüklenemedi: $error');

          // Belirli bir süre sonra tekrar dene
          Future.delayed(_config.minLoadAttemptDelay, () {
            if (_interstitialLoadAttempts < _config.maxFailedLoadAttempts) {
              loadInterstitialAd(callbacks: callbacks);
            }
          });
        },
      ),
    );
  }

  /// Ödüllü reklam yükleme
  Future<void> loadRewardedAd({AdCallbacks? callbacks}) async {
    if (_rewardedState == AdLoadState.loading) return;
    if (_rewardedLoadAttempts >= _config.maxFailedLoadAttempts) return;

    _rewardedState = AdLoadState.loading;

    await RewardedAd.load(
      adUnitId: _config.adIds.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedState = AdLoadState.loaded;
          _rewardedLoadAttempts = 0;
          callbacks?.onAdLoaded?.call();
          debugPrint('Ödüllü reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          _rewardedState = AdLoadState.error;
          _rewardedLoadAttempts++;
          callbacks?.onAdFailedToLoad?.call(error);
          debugPrint('Ödüllü reklam yüklenemedi: $error');

          // Belirli bir süre sonra tekrar dene
          Future.delayed(_config.minLoadAttemptDelay, () {
            if (_rewardedLoadAttempts < _config.maxFailedLoadAttempts) {
              loadRewardedAd(callbacks: callbacks);
            }
          });
        },
      ),
    );
  }

  /// Native reklam yükleme
  Future<void> loadNativeAd({AdCallbacks? callbacks}) async {
    if (_nativeState == AdLoadState.loading) return;
    _nativeState = AdLoadState.loading;

    _nativeAd = NativeAd(
      adUnitId: _config.adIds.nativeId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _nativeState = AdLoadState.loaded;
          callbacks?.onAdLoaded?.call();
          debugPrint('Native reklam yüklendi.');
        },
        onAdFailedToLoad: (ad, error) {
          _nativeState = AdLoadState.error;
          ad.dispose();
          callbacks?.onAdFailedToLoad?.call(error);
          debugPrint('Native reklam yüklenemedi: $error');
        },
      ),
    );
    return _nativeAd!.load();
  }

  /// AppOpen reklam yükleme
  Future<void> loadAppOpenAd({AdCallbacks? callbacks}) async {
    if (_appOpenState == AdLoadState.loading) return;
    _appOpenState = AdLoadState.loading;

    await AppOpenAd.load(
      adUnitId: _config.adIds.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenState = AdLoadState.loaded;
          _isAppOpenAdAvailable = true;
          callbacks?.onAdLoaded?.call();
          debugPrint('App Open reklam yüklendi.');
        },
        onAdFailedToLoad: (error) {
          _appOpenState = AdLoadState.error;
          _isAppOpenAdAvailable = false;
          callbacks?.onAdFailedToLoad?.call(error);
          debugPrint('App Open reklam yüklenemedi: $error');
        },
      ),
    );
  }

  /// Reklam yükleme durumlarını kontrol etme
  bool isAdLoaded(AdType type) {
    switch (type) {
      case AdType.banner:
        return _bannerState == AdLoadState.loaded;
      case AdType.interstitial:
        return _interstitialState == AdLoadState.loaded;
      case AdType.rewarded:
        return _rewardedState == AdLoadState.loaded;
      case AdType.native:
        return _nativeState == AdLoadState.loaded;
      case AdType.appOpen:
        return _appOpenState == AdLoadState.loaded;
    }
  }

  /// Reklam gösterilmeden önce yükleme kontrolü ve yükleme
  Future<bool> _ensureAdLoaded(AdType type) async {
    if (isAdLoaded(type)) return true;

    switch (type) {
      case AdType.banner:
        await loadBannerAd();
        break;
      case AdType.interstitial:
        await loadInterstitialAd();
        break;
      case AdType.rewarded:
        await loadRewardedAd();
        break;
      case AdType.native:
        await loadNativeAd();
        break;
      case AdType.appOpen:
        await loadAppOpenAd();
        break;
    }

    return isAdLoaded(type);
  }

  /// Banner reklamı gösterme
  Widget showBannerAd() {
    _ensureAdLoaded(AdType.banner);
    if (_bannerAd == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// Geçiş reklamı gösterme
  Future<void> showInterstitialAd({
    AdCallbacks? callbacks,
    Duration? minInterval,
  }) async {
    if (!await _ensureAdLoaded(AdType.interstitial)) return;
    if (_interstitialAd == null) return;

    // Minimum gösterim aralığı kontrolü
    if (minInterval != null && _lastInterstitialShowTime != null) {
      final timeSinceLastShow =
          DateTime.now().difference(_lastInterstitialShowTime!);
      if (timeSinceLastShow < minInterval) return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShowTime = DateTime.now();
        callbacks?.onAdShown?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        callbacks?.onAdDismissed?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        callbacks?.onAdFailedToLoad?.call(error);
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// Ödüllü reklam gösterme
  Future<void> showRewardedAd({AdCallbacks? callbacks}) async {
    if (!await _ensureAdLoaded(AdType.rewarded)) return;
    if (_rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        callbacks?.onAdShown?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        callbacks?.onAdDismissed?.call();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        callbacks?.onAdFailedToLoad?.call(error);
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        callbacks?.onUserEarnedReward?.call(reward);
        debugPrint('Kullanıcı ${reward.amount} ${reward.type} kazandı.');
      },
    );
    _rewardedAd = null;
  }

  /// Native reklam gösterme
  Widget showNativeAd({double height = 72.0}) {
    _ensureAdLoaded(AdType.native);
    if (_nativeAd == null) return const SizedBox.shrink();
    return Container(
      height: height,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }

  /// AppOpen reklam gösterme
  Future<void> showAppOpenAd({AdCallbacks? callbacks}) async {
    if (!_isAppOpenAdAvailable) return;
    if (_isShowingAd) return;
    if (_appOpenAd == null) return;

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        callbacks?.onAdShown?.call();
        debugPrint('App Open reklam gösterildi.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open reklam gösterilemedi: $error');
        _isShowingAd = false;
        callbacks?.onAdFailedToLoad?.call(error);
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open reklam kapatıldı.');
        _isShowingAd = false;
        callbacks?.onAdDismissed?.call();
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );

    await _appOpenAd!.show();
  }

  /// App lifecycle değişikliklerini yönet
  void handleAppStateChange(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showAppOpenAdIfAvailable();
    }
  }

  /// App Open reklamı varsa göster
  void showAppOpenAdIfAvailable() {
    if (_appOpenAd == null) return;
    if (_appOpenState != AdLoadState.loaded) return;

    _appOpenAd!.show();
    _appOpenState = AdLoadState.shown;
  }

  /// Kaynakları temizleme
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _nativeAd?.dispose();
    _appOpenAd?.dispose();
  }
}

/// Reklam tiplerini belirten enum
enum AdType { banner, interstitial, rewarded, native, appOpen }
