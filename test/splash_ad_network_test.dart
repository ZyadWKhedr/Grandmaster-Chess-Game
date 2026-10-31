import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/core/services/network_service.dart';
import 'package:grandmaster_chess/features/splash/presentation/providers/splash_notifier.dart';

class MockNetworkService implements NetworkService {
  final bool isConnected;
  MockNetworkService({required this.isConnected});

  @override
  Future<bool> hasInternetConnection() async => isConnected;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Screen Network & Ad Loading Tests', () {
    test('Skips loading ads when no internet connection is present', () async {
      final container = ProviderContainer(
        overrides: [
          networkServiceProvider.overrideWithValue(
            MockNetworkService(isConnected: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep alive autoDispose provider
      final sub = container.listen(splashProvider, (_, __) {});
      addTearDown(sub.close);

      // Wait for async network check
      await Future.delayed(const Duration(milliseconds: 150));

      final state = container.read(splashProvider);
      expect(state.hasInternet, isFalse);
      expect(state.adsLoaded, isTrue);
      expect(state.loadingMessage, 'Offline mode...');
    });

    test('Loads ads when internet connection is active', () async {
      final container = ProviderContainer(
        overrides: [
          networkServiceProvider.overrideWithValue(
            MockNetworkService(isConnected: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(splashProvider, (_, __) {});
      addTearDown(sub.close);

      // Wait for network check and ad load attempt
      await Future.delayed(const Duration(milliseconds: 550));

      final state = container.read(splashProvider);
      expect(state.hasInternet, isTrue);
      expect(state.adsLoaded, isTrue);
    });
  });
}
