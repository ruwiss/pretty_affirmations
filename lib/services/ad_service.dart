import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reklam yükleme durumlarını takip etmek için enum
enum AdLoadState { initial, loading, loaded, error, shown }

/// Reklam hatalarını tanımlamak için enum
enum AdErrorType {
  network, // Ağ bağlantısı hatası
  timeout, // Zaman aşımı hatası
  noFill, // Reklam bulunamadı (error code 3)
  invalid, // Geçersiz reklam kimliği
  unknown // Bilinmeyen hata
}

/// Reklam durumunu yönetmek için sınıf
class AdState {
  AdLoadState loadState;
  int loadAttempts;
  DateTime? lastShowTime;
  DateTime? lastAttemptTime;
  AdErrorType? lastError;
  Duration retryDelay;

  AdState({
    this.loadState = AdLoadState.initial,
    this.loadAttempts = 0,
    this.lastShowTime,
    this.lastAttemptTime,
    this.lastError,
    this.retryDelay = const Duration(seconds: 1),
  });

  bool get canRetry => loadAttempts < 3;

  void incrementAttempts() {
    loadAttempts++;
    lastAttemptTime = DateTime.now();
    // Üstel artış ile bekleme süresini güncelle
    retryDelay = Duration(seconds: pow(2, loadAttempts).toInt());
  }

  void reset() {
    loadState = AdLoadState.initial;
    loadAttempts = 0;
    lastError = null;
    retryDelay = const Duration(seconds: 1);
  }
}

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
        nativeId: 'ca-app-pub-3940256099942544/2247696110',
        appOpenId: 'ca-app-pub-3940256099942544/9257395921',
      );
}

/// Reklam konfigürasyonu için model
class AdConfig {
  final AdIds adIds;
  final bool testAds;
  final Duration minLoadAttemptDelay;
  final int maxFailedLoadAttempts;
  final bool disabled;

  const AdConfig({
    required this.adIds,
    required this.testAds,
    this.minLoadAttemptDelay = const Duration(seconds: 1),
    this.maxFailedLoadAttempts = 3,
    this.disabled = false,
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

/// Ödül reklamı için callback model
class RewardAdCallbacks extends AdCallbacks {
  final Function(RewardItem)? onRewardEarned;

  const RewardAdCallbacks({
    super.onAdLoaded,
    super.onAdFailedToLoad,
    super.onAdShown,
    super.onAdDismissed,
    this.onRewardEarned,
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

  // Her reklam tipi için AdState Map'leri
  final Map<String, AdState> _bannerStates = {};
  final Map<String, AdState> _interstitialStates = {};
  final Map<String, AdState> _rewardedStates = {};
  final Map<String, AdState> _nativeStates = {};
  final Map<String, AdState> _appOpenStates = {};

  /// Servisi başlatmak için init metodu
  void init(AdConfig config) {
    // Konfigürasyon doğrulaması
    if (config.adIds.bannerId.isEmpty &&
        config.adIds.interstitialId.isEmpty &&
        config.adIds.rewardedId.isEmpty &&
        config.adIds.nativeId.isEmpty &&
        config.adIds.appOpenId.isEmpty) {
      ArgumentError('En az bir reklam ID\'si sağlanmalıdır');
    }
    _config = config;
  }

  /// Hata tipini belirle
  AdErrorType _getErrorType(LoadAdError error) {
    switch (error.code) {
      case 0:
        return AdErrorType.network;
      case 1:
        return AdErrorType.invalid;
      case 2:
        return AdErrorType.timeout;
      case 3:
        return AdErrorType.noFill;
      default:
        return AdErrorType.unknown;
    }
  }

  /// Yeniden deneme mantığı
  Future<void> _handleRetry(
      String key, AdState state, Future<void> Function() loadAd) async {
    if (!state.canRetry) return;

    state.incrementAttempts();
    debugPrint(
        'Reklam yükleme yeniden deneniyor. Deneme: ${state.loadAttempts}, Bekleme süresi: ${state.retryDelay.inSeconds}s');

    await Future.delayed(state.retryDelay);
    if (state.loadState != AdLoadState.loaded) {
      await loadAd();
    }
  }

  /// Banner reklam yükleme
  Future<void> loadBannerAd({
    String key = "app",
    String? adUnitId,
    AdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
    if (_bannerAds[key] != null ||
        _bannerStates[key]?.loadState == AdLoadState.loading) {
      return;
    }

    final state = AdState();
    _bannerStates[key] = state;

    try {
      final bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _config.testAds
            ? _testAds.bannerId
            : adUnitId ?? _config.adIds.bannerId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            state.loadState = AdLoadState.loaded;
            _bannerAds[key] = ad as BannerAd;
            callbacks?.onAdLoaded?.call();
            debugPrint('Banner reklam yüklendi: $key');
          },
          onAdFailedToLoad: (ad, error) async {
            state.loadState = AdLoadState.error;
            state.lastError = _getErrorType(error);
            _bannerAds[key]?.dispose();
            _bannerAds[key] = null;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Banner reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            await _handleRetry(
                key,
                state,
                () => loadBannerAd(
                    key: key, adUnitId: adUnitId, callbacks: callbacks));
          },
        ),
        request: const AdRequest(),
      );

      await bannerAd.load();
    } catch (e) {
      debugPrint('Banner reklam yüklenirken hata: $key, Hata: $e');
      state.loadState = AdLoadState.error;
      _bannerAds[key]?.dispose();
      _bannerAds[key] = null;
    }
  }

  /// Geçiş reklamı yükleme
  Future<void> loadInterstitialAd({
    String key = "app",
    String? adUnitId,
    AdCallbacks? callbacks,
  }) async {
       if (_config.disabled) return;
    if (_interstitialAds[key] != null ||
        _interstitialStates[key]?.loadState == AdLoadState.loading) {
      return;
    }
    if (_interstitialStates[key]?.loadAttempts ==
        _config.maxFailedLoadAttempts) {
      return;
    }

    final state = AdState();
    _interstitialStates[key] = state;

    try {
      await InterstitialAd.load(
        adUnitId: _config.testAds
            ? _testAds.interstitialId
            : adUnitId ?? _config.adIds.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            state.loadState = AdLoadState.loaded;
            _interstitialAds[key] = ad;
            state.loadAttempts = 0;
            callbacks?.onAdLoaded?.call();
            debugPrint('Geçiş reklamı yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _interstitialAds[key]?.dispose();
                _interstitialAds[key] = null;
                state.loadState = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) async {
            state.loadState = AdLoadState.error;
            state.lastError = _getErrorType(error);
            state.loadAttempts++;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Geçiş reklamı yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            await _handleRetry(
                key,
                state,
                () => loadInterstitialAd(
                    key: key, adUnitId: adUnitId, callbacks: callbacks));
          },
        ),
      );
    } catch (e) {
      debugPrint('Geçiş reklamı yüklenirken hata: $key, Hata: $e');
      state.loadState = AdLoadState.error;
      _interstitialAds[key]?.dispose();
      _interstitialAds[key] = null;
    }
  }

  /// Ödül reklamı yükleme
  Future<void> loadRewardedAd({
    String key = "app",
    String? adUnitId,
    RewardAdCallbacks? callbacks,
  }) async {
       if (_config.disabled) return;
    if (_rewardedAds[key] != null ||
        _rewardedStates[key]?.loadState == AdLoadState.loading) {
      return;
    }
    if (_rewardedStates[key]?.loadAttempts == _config.maxFailedLoadAttempts) {
      return;
    }

    final state = AdState();
    _rewardedStates[key] = state;

    try {
      await RewardedAd.load(
        adUnitId: _config.testAds
            ? _testAds.rewardedId
            : adUnitId ?? _config.adIds.rewardedId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            state.loadState = AdLoadState.loaded;
            _rewardedAds[key] = ad;
            state.loadAttempts = 0;
            callbacks?.onAdLoaded?.call();
            debugPrint('Ödül reklamı yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _rewardedAds[key]?.dispose();
                _rewardedAds[key] = null;
                state.loadState = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) async {
            state.loadState = AdLoadState.error;
            state.lastError = _getErrorType(error);
            state.loadAttempts++;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Ödül reklamı yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            await _handleRetry(
                key,
                state,
                () => loadRewardedAd(
                    key: key, adUnitId: adUnitId, callbacks: callbacks));
          },
        ),
      );
    } catch (e) {
      debugPrint('Ödül reklamı yüklenirken hata: $key, Hata: $e');
      state.loadState = AdLoadState.error;
      _rewardedAds[key]?.dispose();
      _rewardedAds[key] = null;
    }
  }

  /// Native reklam yükleme
  Future<void> loadNativeAd({
    String key = "app",
    String? adUnitId,
    AdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
    if (_nativeAds[key] != null ||
        _nativeStates[key]?.loadState == AdLoadState.loading) {
      return;
    }

    final state = AdState();
    _nativeStates[key] = state;

    try {
      final nativeAd = NativeAd(
        adUnitId: _config.testAds
            ? _testAds.nativeId
            : adUnitId ?? _config.adIds.nativeId,
        factoryId: 'adFactoryMedium',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            state.loadState = AdLoadState.loaded;
            _nativeAds[key] = ad as NativeAd;
            callbacks?.onAdLoaded?.call();
            debugPrint('Native reklam yüklendi: $key');
          },
          onAdFailedToLoad: (ad, error) async {
            state.loadState = AdLoadState.error;
            state.lastError = _getErrorType(error);
            _nativeAds[key]?.dispose();
            _nativeAds[key] = null;
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'Native reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            await _handleRetry(
                key,
                state,
                () => loadNativeAd(
                    key: key, adUnitId: adUnitId, callbacks: callbacks));
          },
        ),
        request: const AdRequest(),
      );

      _nativeAds[key] = nativeAd;
      await nativeAd.load();
    } catch (e) {
      debugPrint('Native reklam yüklenirken hata: $key, Hata: $e');
      state.loadState = AdLoadState.error;
      _nativeAds[key]?.dispose();
      _nativeAds[key] = null;
    }
  }

  /// AppOpen reklam yükleme
  Future<void> loadAppOpenAd({
    String key = "app",
    String? adUnitId,
    AdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
    if (_appOpenAds[key] != null ||
        _appOpenStates[key]?.loadState == AdLoadState.loading) {
      return;
    }

    final state = AdState();
    _appOpenStates[key] = state;

    try {
      await AppOpenAd.load(
        adUnitId: _config.testAds
            ? _testAds.appOpenId
            : adUnitId ?? _config.adIds.appOpenId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            state.loadState = AdLoadState.loaded;
            _appOpenAds[key] = ad;
            callbacks?.onAdLoaded?.call();
            debugPrint('AppOpen reklam yüklendi: $key');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _appOpenAds[key]?.dispose();
                _appOpenAds[key] = null;
                state.loadState = AdLoadState.initial;
                callbacks?.onAdDismissed?.call();
              },
            );
          },
          onAdFailedToLoad: (error) async {
            state.loadState = AdLoadState.error;
            state.lastError = _getErrorType(error);
            callbacks?.onAdFailedToLoad?.call(error);
            debugPrint(
                'AppOpen reklam yüklenemedi: $key, Hata: ${error.message} (${error.code})');

            await _handleRetry(
                key,
                state,
                () => loadAppOpenAd(
                    key: key, adUnitId: adUnitId, callbacks: callbacks));
          },
        ),
      );
    } catch (e) {
      debugPrint('AppOpen reklam yüklenirken hata: $key, Hata: $e');
      state.loadState = AdLoadState.error;
      _appOpenAds[key]?.dispose();
      _appOpenAds[key] = null;
    }
  }

  /// Reklamın gösterilebilir olup olmadığını kontrol et
  bool _adCanBeShown(AdState? state) {
    if (state?.lastShowTime == null) return true;
    final sonGosterimdenBeriGecenSure =
        DateTime.now().difference(state!.lastShowTime!);
    return sonGosterimdenBeriGecenSure >= _config.minLoadAttemptDelay;
  }

  /// Banner reklamın yüklenip yüklenmediğini kontrol et
  bool isBannerAdLoaded({String key = "app"}) =>
      _bannerAds[key] != null &&
      _bannerStates[key]?.loadState == AdLoadState.loaded;

  /// Geçiş reklamının yüklenip yüklenmediğini kontrol et
  bool isInterstitialAdLoaded({String key = "app"}) =>
      _interstitialAds[key] != null &&
      _interstitialStates[key]?.loadState == AdLoadState.loaded;

  /// Ödül reklamının yüklenip yüklenmediğini kontrol et
  bool isRewardedAdLoaded({String key = "app"}) =>
      _rewardedAds[key] != null &&
      _rewardedStates[key]?.loadState == AdLoadState.loaded;

  /// Native reklamın yüklenip yüklenmediğini kontrol et
  bool isNativeAdLoaded({String key = "app"}) =>
      _nativeAds[key] != null &&
      _nativeStates[key]?.loadState == AdLoadState.loaded;

  /// AppOpen reklamın yüklenip yüklenmediğini kontrol et
  bool isAppOpenAdLoaded({String key = "app"}) =>
      _appOpenAds[key] != null &&
      _appOpenStates[key]?.loadState == AdLoadState.loaded;

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
  Future<void> showInterstitialAd({
    String key = "app",
    AdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
    final interstitialAd = _interstitialAds[key];
    final state = _interstitialStates[key];

    if (interstitialAd == null || state?.loadState != AdLoadState.loaded) {
      return;
    }

    // Son gösterim zamanını kontrol et
    if (!_adCanBeShown(state)) return;

    await interstitialAd.show();
    state?.lastShowTime = DateTime.now();
    callbacks?.onAdShown?.call();
  }

  /// Ödül reklamı göster
  Future<void> showRewardedAd({
    String key = "app",
    RewardAdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
    final rewardedAd = _rewardedAds[key];
    final state = _rewardedStates[key];

    if (rewardedAd == null || state?.loadState != AdLoadState.loaded) return;

    // Son gösterim zamanını kontrol et
    if (!_adCanBeShown(state)) return;

    await rewardedAd.show(onUserEarnedReward: (ad, reward) {
      callbacks?.onRewardEarned?.call(reward);
      state?.lastShowTime = DateTime.now();
    });

    callbacks?.onAdShown?.call();
  }

  /// AppOpen reklamı göster
  Future<void> showAppOpenAd({
    String key = "app",
    AdCallbacks? callbacks,
  }) async {
    if (_config.disabled) return;
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
    try {
      // Reklam instance'larını temizle
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

      // Haritaları temizle
      _bannerAds.clear();
      _interstitialAds.clear();
      _rewardedAds.clear();
      _nativeAds.clear();
      _appOpenAds.clear();

      // Durum haritalarını temizle
      _bannerStates.clear();
      _interstitialStates.clear();
      _rewardedStates.clear();
      _nativeStates.clear();
      _appOpenStates.clear();
    } catch (e) {
      debugPrint('Kaynakları temizlerken hata oluştu: $e');
    }
  }
}
