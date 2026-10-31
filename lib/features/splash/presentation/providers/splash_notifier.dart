import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:grandmaster_chess/core/providers/ad_provider.dart';
import 'package:grandmaster_chess/core/services/network_service.dart';
import 'package:grandmaster_chess/features/splash/presentation/providers/splash_state.dart';

class SplashNotifier extends StateNotifier<SplashState> {
  final Ref _ref;
  Timer? _minTimer;
  Timer? _maxTimer;

  SplashNotifier(this._ref) : super(const SplashState()) {
    _initialize();
  }

  void _initialize() {
    _checkNetworkAndLoadAds();
    _startTimers();
  }

  Future<void> _checkNetworkAndLoadAds() async {
    try {
      final networkService = _ref.read(networkServiceProvider);
      final hasInternet = await networkService.hasInternetConnection();

      if (!mounted) return;

      if (!hasInternet) {
        debugPrint('SplashNotifier: No internet connection. Skipping ads.');
        state = state.copyWith(
          hasInternet: false,
          adsLoaded: true,
          status: state.minTimeElapsed
              ? SplashStatus.ready
              : SplashStatus.adsLoaded,
          loadingMessage: 'Offline mode...',
        );
        return;
      }

      debugPrint('SplashNotifier: Internet connection active. Loading ads...');
      state = state.copyWith(
        hasInternet: true,
        loadingMessage: 'Preparing tournament...',
      );

      final bannerNotifier = _ref.read(bannerAdProvider.notifier);
      await bannerNotifier.loadAd();

      final interstitialService = _ref.read(interstitialAdProvider);
      interstitialService.loadAd();

      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) {
        state = state.copyWith(
          adsLoaded: true,
          status: state.minTimeElapsed
              ? SplashStatus.ready
              : SplashStatus.adsLoaded,
          loadingMessage: 'Starting...',
        );
      }
    } catch (e) {
      debugPrint('SplashNotifier: Error during network/ad load: $e');
      if (mounted) {
        state = state.copyWith(
          adsLoaded: true,
          status: state.minTimeElapsed
              ? SplashStatus.ready
              : SplashStatus.adsLoaded,
          loadingMessage: 'Starting...',
        );
      }
    }
  }

  void _startTimers() {
    _minTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        state = state.copyWith(
          minTimeElapsed: true,
          status: state.adsLoaded ? SplashStatus.ready : state.status,
        );
      }
    });

    _maxTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !state.adsLoaded) {
        state = state.copyWith(
          adsLoaded: true,
          status: SplashStatus.ready,
          loadingMessage: 'Starting...',
        );
      }
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _maxTimer?.cancel();
    super.dispose();
  }
}

final splashProvider =
    StateNotifierProvider.autoDispose<SplashNotifier, SplashState>((ref) {
      return SplashNotifier(ref);
    });
