// chess_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/features/settings/presentation/pages/settings_page.dart';

import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/banner_ad_widget.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/chess_home_actions.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/chess_home_app_bar.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/home_logo.dart';

class ChessHomePage extends ConsumerWidget {
  const ChessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const ChessHomeAppBar(),
      endDrawer: const SettingsPage(),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const HomeLogo(),
                        const SizedBox(height: 60),
                        const ChessHomeActions(),
                      ],
                    ),
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}