import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:grandmaster_chess/features/settings/presentation/widgets/settings_tile.dart';
import 'package:grandmaster_chess/features/settings/presentation/pages/language_page.dart';
import 'package:grandmaster_chess/features/settings/presentation/pages/theme_page.dart';
import 'package:grandmaster_chess/features/settings/presentation/pages/about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'settings'.tr(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 24),

              SettingsTile(
                icon: Icons.language_rounded,
                title: 'languages'.tr(),
                subtitle: 'change_app_language'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguagePage()),
                  );
                },
              ),

              const SizedBox(height: 24),

              SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'theme'.tr(),
                subtitle: 'light_dark'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ThemePage()),
                  );
                },
              ),

              const SizedBox(height: 24),

              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'about'.tr(),
                subtitle: 'developer_info'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),

              const Spacer(),

              Center(
                child: Text(
                  'GrandMaster Chess v2.1.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
