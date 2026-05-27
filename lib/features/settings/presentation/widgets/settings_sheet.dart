import 'package:flutter/material.dart';

import 'package:grandmaster_chess/features/settings/presentation/widgets/settings_tile.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 24),

          SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English / العربية',
            onTap: () {},
          ),

          SettingsTile(
            icon: Icons.palette_rounded,
            title: 'Board Theme',
            subtitle: 'Classic',
            onTap: () {},
          ),

          SettingsTile(
            icon: Icons.volume_up_rounded,
            title: 'Sound Effects',
            subtitle: 'Enabled',
            onTap: () {},
          ),

          const Divider(height: 32),

          SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'App version and developer info',
            onTap: () {},
          ),

          SettingsTile(
            icon: Icons.public_rounded,
            title: 'Portfolio',
            subtitle: 'Open developer website',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}