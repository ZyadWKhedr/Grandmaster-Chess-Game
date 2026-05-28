import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:grandmaster_chess/features/settings/presentation/widgets/settings_tile.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      ('English', 'en', '🇺🇸'),
      ('العربية', 'ar', '🇪🇬'),
      ('Deutsch', 'de', '🇩🇪'),
      ('Français', 'fr', '🇫🇷'),
      ('हिन्दी', 'hi', '🇮🇳'),
      ('Русский', 'ru', '🇷🇺'),
      ('中文', 'zh', '🇨🇳'),
      ('日本語', 'ja', '🇯🇵'),
      ('Português', 'pt', '🇵🇹'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('languages').tr()),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final language = languages[index];

          return SettingsTile(
            icon: Icons.language_rounded,
            title: '${language.$3} ${language.$1}',
            subtitle: language.$2.toUpperCase(),
            onTap: () async {
              await context.setLocale(Locale(language.$2));
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          );
        },
      ),
    );
  }
}
