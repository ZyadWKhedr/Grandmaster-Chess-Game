import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';

class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('choose_theme'.tr()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            RadioListTile<ThemeMode>(
              title: Text('system_theme'.tr()),
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('light_mode'.tr()),
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text('dark_mode'.tr()),
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeProvider.notifier).state = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
