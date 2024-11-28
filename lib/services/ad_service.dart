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
    this.bannerId = "",
    this.interstitialId = "",
    this.rewardedId = "",
    this.nativeId = "",
    this.appOpenId = "",
  });

  /// Test reklamları için factory constructor
  factory AdIds.test() => const AdIds(
        bannerId: 'ca-app-pub-3940256099942544/6300978111',
        interstitialId: 'ca-app-pub-3940256099942544/1033173712',
        rewardedId: 'ca-app-pub-3940256099942544/5224354917',
        nativeId: 'ca-app-pub-39402error56099942544/2247696110',
        appOpenId: 'ca-app-pub-3940256099942544/9257395921',
      );
}

/// Reklam konfigürasyonu için model
class AdConfig {
  final AdIds adIds;
  final bool testAds;
  final Duration minLoadAttemptDelay;
  final int maxFailedLoadAttempts;

  const AdConfig({
    required this.adIds,
    required this.testAds,
    this.minLoadAttemptDelay = const Duration(seconds: 1),
    this.maxFailedLoadAttempts = 3,
  });
}

/// Reklam yükleme ve hata callback'leri için model
class AdCallbacks {
  final VoidCallback? onAdLoaded;
  final Function(LoadAdError)? onAdFailedToLoad;
  final VoidCallback? onAdShown;
  final VoidCallback? onAdDismissed;

  const AdCallbacks({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdShown,
    this.onAdDismissed,
  });
}

/// Reklam servisimiz
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  late final AdConfig _config;
  final AdIds _testAds = AdIds.test();

  // Her reklam tipi için Map'ler
  final Map<String, BannerAd?> _bannerAds = {};
  final Map<String, InterstitialAd?> _interstitialAds = {};
  final Map<String, RewardedAd?> _rewardedAds = {};
  final Map<String, NativeAd?> _nativeAds = {};
  final Map<String, AppOpenAd?> _appOpenAds = {};

  // Her reklam tipi için state Map'leri
  final Map<String, AdLoadState> _bannerStates = {};
  final Map<String, AdLoadState> _interstitialStates = {};
  final Map<String, AdLoadState> _rewardedStates = {};
  final Map<String, AdLoadState> _nativeStates = {};
  final Map<String, AdLoadState> _appOpenStates = {};

  // Her reklam tipi için yükleme deneme sayıları
  final Map<String, int> _interstitialLoadAttempts = {};
  final Map<String, int> _rewardedLoadAttempts = {};
  final Map<String, DateTime?> _lastInterstitialShowTimes = {};

  /// Servisi başlatmak için init metodu
  void init(AdConfig config) {
    _config = config;
  }

  /// Banner reklam yükleme
  Future<void> loadBannerAd(
      {String key = "app", String? adUnitId, AdCallbacks? callbacks}) async {
    if (_bannerAds[key] != null || _bannerStates[key] == AdLoadState.loading) {
      return;
    }

    _bannerStates[key] = AdLoadState.loading;

    try {
      final bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _config.testAds
            ? _testAds.bannerId
            : adUnitId ?? _config.adIds.bannerId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _bannerStates[key] = AdLoadState.loaded;
            _bannerAds[key] = ad as BannerAd;
            callbacks?.onAdLoaded?.call();
            debugPrint('Banner reklam yüklendi: $key');
          },
          onAdFailedToLoad: (ad, error) {
            _bannerStates[key] = AdLoadState.error;
            _bannerAds[key]?.dispose();
            _bannerAds[key] = null;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Banner reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            // Belirli bir süre sonra tekrar dene
            if (error.code == 3) {
              Future.delayed(const Duration(minutes: 1), () {
                if (_bannerStates[key] != AdLoadState.loaded) {
                  loadBannerAd(
                      key: key, adUnitId: adUnitId, callbacks: callbacks);
                }
              });
            }
          },
        ),
        request: const AdRequest(),
      );

      await bannerAd.load();
    } catch (e) {
      debugPrint('Banner reklam yüklenirken hata: $key, Hata: $e');
      _bannerStates[key] = AdLoadState.error;
      _bannerAds[key]?.dispose();
      _bannerAds[key] = null;
    }
  }

  /// Geçiş reklamı yükleme
  Future<void> loadInterstitialAd(
      {String key = "app", String? adUnitId, AdCallbacks? callbacks}) async {
    if (_interstitialAds[key] != null ||
        _interstitialStates[key] == AdLoadState.loading) return;
    if (_interstitialLoadAttempts[key] == _config.maxFailedLoadAttempts) return;

    _interstitialStates[key] = AdLoadState.loading;

    try {
      await InterstitialAd.load(
        adUnitId: _config.testAds
            ? _testAds.interstitialId
            : adUnitId ?? _config.adIds.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAds[key] = ad;
            _interstitialStates[key] = AdLoadState.loaded;
            _interstitialLoadAttempts[key] = 0;
            callbacks?.onAdLoaded?.call();
            debugPrint('Geçiş reklamı yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _interstitialAds[key]?.dispose();
                _interstitialAds[key] = null;
                _interstitialStates[key] = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _interstitialStates[key] = AdLoadState.error;
            _interstitialLoadAttempts[key] =
                (_interstitialLoadAttempts[key] ?? 0) + 1;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Geçiş reklamı yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            // Belirli bir süre sonra tekrar dene
            if (error.code == 3) {
              Future.delayed(const Duration(minutes: 1), () {
                if (_interstitialStates[key] != AdLoadState.loaded) {
                  loadInterstitialAd(
                      key: key, adUnitId: adUnitId, callbacks: callbacks);
                }
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Geçiş reklamı yüklenirken hata: $key, Hata: $e');
      _interstitialStates[key] = AdLoadState.error;
      _interstitialAds[key]?.dispose();
      _interstitialAds[key] = null;
    }
  }

  /// Ödül reklamı yükleme
  Future<void> loadRewardedAd(
      {String key = "app", String? adUnitId, AdCallbacks? callbacks}) async {
    if (_rewardedAds[key] != null ||
        _rewardedStates[key] == AdLoadState.loading) return;
    if (_rewardedLoadAttempts[key] == _config.maxFailedLoadAttempts) return;

    _rewardedStates[key] = AdLoadState.loading;

    try {
      await RewardedAd.load(
        adUnitId: _config.testAds
            ? _testAds.rewardedId
            : adUnitId ?? _config.adIds.rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAds[key] = ad;
            _rewardedStates[key] = AdLoadState.loaded;
            _rewardedLoadAttempts[key] = 0;
            callbacks?.onAdLoaded?.call();
            debugPrint('Ödül reklamı yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _rewardedAds[key]?.dispose();
                _rewardedAds[key] = null;
                _rewardedStates[key] = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _rewardedStates[key] = AdLoadState.error;
            _rewardedLoadAttempts[key] = (_rewardedLoadAttempts[key] ?? 0) + 1;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Ödül reklamı yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            // Belirli bir süre sonra tekrar dene
            if (error.code == 3) {
              Future.delayed(const Duration(minutes: 1), () {
                if (_rewardedStates[key] != AdLoadState.loaded) {
                  loadRewardedAd(
                      key: key, adUnitId: adUnitId, callbacks: callbacks);
                }
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Ödül reklamı yüklenirken hata: $key, Hata: $e');
      _rewardedStates[key] = AdLoadState.error;
      _rewardedAds[key]?.dispose();
      _rewardedAds[key] = null;
    }
  }

  /// Native reklam yükleme
  Future<void> loadNativeAd(
      {String key = "app", String? adUnitId, AdCallbacks? callbacks}) async {
    if (_nativeAds[key] != null || _nativeStates[key] == AdLoadState.loading) {
      return;
    }

    _nativeStates[key] = AdLoadState.loading;

    try {
      final nativeAd = NativeAd(
        adUnitId: _config.testAds
            ? _testAds.nativeId
            : adUnitId ?? _config.adIds.nativeId,
        factoryId: 'adFactoryMedium',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _nativeAds[key] = ad as NativeAd;
            _nativeStates[key] = AdLoadState.loaded;
            callbacks?.onAdLoaded?.call();
            debugPrint('Native reklam yüklendi: $key');
          },
          onAdFailedToLoad: (ad, error) {
            _nativeStates[key] = AdLoadState.error;
            _nativeAds[key]?.dispose();
            _nativeAds[key] = null;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Native reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            // Belirli bir süre sonra tekrar dene
            if (error.code == 3) {
              Future.delayed(const Duration(minutes: 1), () {
                if (_nativeStates[key] != AdLoadState.loaded) {
                  loadNativeAd(
                      key: key, adUnitId: adUnitId, callbacks: callbacks);
                }
              });
            }
          },
        ),
        request: const AdRequest(),
      );

      _nativeAds[key] = nativeAd;
      await nativeAd.load();
    } catch (e) {
      debugPrint('Native reklam yüklenirken hata: $key, Hata: $e');
      _nativeStates[key] = AdLoadState.error;
      _nativeAds[key]?.dispose();
      _nativeAds[key] = null;
    }
  }

  /// AppOpen reklam yükleme
  Future<void> loadAppOpenAd(
      {String key = "app", String? adUnitId, AdCallbacks? callbacks}) async {
    if (_appOpenAds[key] != null ||
        _appOpenStates[key] == AdLoadState.loading) {
      return;
    }

    _appOpenStates[key] = AdLoadState.loading;

    try {
      await AppOpenAd.load(
        adUnitId: _config.testAds
            ? _testAds.appOpenId
            : adUnitId ?? _config.adIds.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAds[key] = ad;
            _appOpenStates[key] = AdLoadState.loaded;
            callbacks?.onAdLoaded?.call();
            debugPrint('AppOpen reklam yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _appOpenAds[key]?.dispose();
                _appOpenAds[key] = null;
                _appOpenStates[key] = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _appOpenStates[key] = AdLoadState.error;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'AppOpen reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            // Belirli bir süre sonra tekrar dene
            if (error.code == 3) {
              Future.delayed(const Duration(minutes: 1), () {
                if (_appOpenStates[key] != AdLoadState.loaded) {
                  loadAppOpenAd(
                      key: key, adUnitId: adUnitId, callbacks: callbacks);
                }
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('AppOpen reklam yüklenirken hata: $key, Hata: $e');
      _appOpenStates[key] = AdLoadState.error;
      _appOpenAds[key]?.dispose();
      _appOpenAds[key] = null;
    }
  }

  /// Banner reklamın yüklenip yüklenmediğini kontrol et
  bool isBannerAdLoaded({String key = "app"}) =>
      _bannerAds[key] != null && _bannerStates[key] == AdLoadState.loaded;

  /// Geçiş reklamının yüklenip yüklenmediğini kontrol et
  bool isInterstitialAdLoaded({String key = "app"}) =>
      _interstitialAds[key] != null &&
      _interstitialStates[key] == AdLoadState.loaded;

  /// Ödül reklamının yüklenip yüklenmediğini kontrol et
  bool isRewardedAdLoaded({String key = "app"}) =>
      _rewardedAds[key] != null && _rewardedStates[key] == AdLoadState.loaded;

  /// Native reklamın yüklenip yüklenmediğini kontrol et
  bool isNativeAdLoaded({String key = "app"}) =>
      _nativeAds[key] != null && _nativeStates[key] == AdLoadState.loaded;

  /// AppOpen reklamın yüklenip yüklenmediğini kontrol et
  bool isAppOpenAdLoaded({String key = "app"}) =>
      _appOpenAds[key] != null && _appOpenStates[key] == AdLoadState.loaded;

  /// Banner reklamı göster
  Widget showBannerAd({String key = "app"}) {
    final bannerAd = _bannerAds[key];
    if (bannerAd == null || !isBannerAdLoaded(key: key)) {
      return const SizedBox();
    }

    return SizedBox(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  /// Geçiş reklamı göster
  Future<void> showInterstitialAd(
      {String key = "app", AdCallbacks? callbacks}) async {
    final interstitialAd = _interstitialAds[key];
    if (interstitialAd == null || !isInterstitialAdLoaded(key: key)) return;

    // Son gösterim zamanını kontrol et
    final lastShowTime = _lastInterstitialShowTimes[key];
    if (lastShowTime != null) {
      final timeSinceLastShow = DateTime.now().difference(lastShowTime);
      if (timeSinceLastShow < _config.minLoadAttemptDelay) return;
    }

    await interstitialAd.show();
    _lastInterstitialShowTimes[key] = DateTime.now();
    callbacks?.onAdShown?.call();
  }

  /// Ödül reklamı göster
  Future<void> showRewardedAd(
      {String key = "app", AdCallbacks? callbacks}) async {
    final rewardedAd = _rewardedAds[key];
    if (rewardedAd == null || !isRewardedAdLoaded(key: key)) return;

    await rewardedAd.show(onUserEarnedReward: (_, reward) {});
    callbacks?.onAdShown?.call();
  }

  /// AppOpen reklamı göster
  Future<void> showAppOpenAd(
      {String key = "app", AdCallbacks? callbacks}) async {
    final appOpenAd = _appOpenAds[key];
    if (appOpenAd == null || !isAppOpenAdLoaded(key: key)) return;

    await appOpenAd.show();
    callbacks?.onAdShown?.call();
  }

  /// App lifecycle değişikliklerini yönet
  void handleAppStateChange(AppLifecycleState state, {String key = "app"}) {
    // Uygulama ön plana geldiğinde
    if (state == AppLifecycleState.resumed) {
      // AppOpen reklamını yükle (eğer yüklü değilse)
      if (!isAppOpenAdLoaded(key: key)) {
        loadAppOpenAd(key: key);
      }
    }
  }

  /// Kaynakları temizleme
  void dispose() {
    for (final ad in _bannerAds.values) {
      ad?.dispose();
    }
    for (final ad in _interstitialAds.values) {
      ad?.dispose();
    }
    for (final ad in _rewardedAds.values) {
      ad?.dispose();
    }
    for (final ad in _nativeAds.values) {
      ad?.dispose();
    }
    for (final ad in _appOpenAds.values) {
      ad?.dispose();
    }

    _bannerAds.clear();
    _interstitialAds.clear();
    _rewardedAds.clear();
    _nativeAds.clear();
    _appOpenAds.clear();

    _bannerStates.clear();
    _interstitialStates.clear();
    _rewardedStates.clear();
    _nativeStates.clear();
    _appOpenStates.clear();

    _interstitialLoadAttempts.clear();
    _rewardedLoadAttempts.clear();
    _lastInterstitialShowTimes.clear();
  }
}
