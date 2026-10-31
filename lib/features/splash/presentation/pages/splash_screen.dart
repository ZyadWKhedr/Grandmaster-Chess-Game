import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/features/splash/presentation/providers/splash_notifier.dart';
import 'package:grandmaster_chess/features/splash/presentation/providers/splash_state.dart';
import 'package:grandmaster_chess/features/splash/presentation/widgets/splash_logo_widget.dart';
import 'package:grandmaster_chess/features/splash/presentation/widgets/splash_title_widget.dart';
import 'package:grandmaster_chess/features/splash/presentation/widgets/splash_loading_widget.dart';
import 'package:grandmaster_chess/features/home/presentation/pages/chess_home_page.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const ChessHomePage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashProvider);

    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.isReady && (previous == null || !previous.isReady)) {
        _navigateToHome(context);
      }
    });

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
              colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const SplashLogoWidget(),
              const SizedBox(height: 36),
              const SplashTitleWidget(),
              const Spacer(flex: 2),
              SplashLoadingWidget(message: splashState.loadingMessage),
            ],
          ),
        ),
      ),
    );
  }
}
