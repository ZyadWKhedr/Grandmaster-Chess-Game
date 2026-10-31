import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_card.dart';
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              _ThemeOptionCard(
                title: 'system_theme'.tr(),
                icon: Icons.brightness_auto_rounded,
                isSelected: themeMode == ThemeMode.system,
                onTap: () =>
                    ref.read(themeProvider.notifier).state = ThemeMode.system,
              ),
              SizedBox(height: 12.h),
              _ThemeOptionCard(
                title: 'light_mode'.tr(),
                icon: Icons.light_mode_rounded,
                isSelected: themeMode == ThemeMode.light,
                onTap: () =>
                    ref.read(themeProvider.notifier).state = ThemeMode.light,
              ),
              SizedBox(height: 12.h),
              _ThemeOptionCard(
                title: 'dark_mode'.tr(),
                icon: Icons.dark_mode_rounded,
                isSelected: themeMode == ThemeMode.dark,
                onTap: () =>
                    ref.read(themeProvider.notifier).state = ThemeMode.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      borderColor: isSelected ? primary : null,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? primary : theme.iconTheme.color,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primary : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: primary, size: 22.sp),
        ],
      ),
    );
  }
}
