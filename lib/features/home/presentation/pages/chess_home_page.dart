import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/core/widgets/dot_grid_background.dart';
import 'package:grandmaster_chess/features/settings/presentation/pages/settings_page.dart';
import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/banner_ad_widget.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/chess_home_app_bar.dart';
import 'package:grandmaster_chess/features/home/presentation/sections/home_actions_section.dart';
import 'package:grandmaster_chess/features/home/presentation/sections/home_hero_section.dart';
import 'package:grandmaster_chess/features/home/presentation/sections/home_match_setup_section.dart';
import 'package:grandmaster_chess/features/home/presentation/sections/home_time_presets_section.dart';

class ChessHomePage extends ConsumerWidget {
  const ChessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const ChessHomeAppBar(),
      endDrawer: const SettingsPage(),
      body: DotGridBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 540.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeHeroSection(),
                          SizedBox(height: 14.h),
                          const HomeMatchSetupSection(),
                          SizedBox(height: 14.h),
                          const HomeActionsSection(),
                          SizedBox(height: 20.h),
                          _buildSectionHeader('QUICK MATCH PRESETS', isDark),
                          SizedBox(height: 8.h),
                          const HomeTimePresetsSection(),
                          SizedBox(height: 16.h),
                        ],
                      ),
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
    );
  }
}
