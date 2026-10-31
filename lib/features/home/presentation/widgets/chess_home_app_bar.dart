import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';

class ChessHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ChessHomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16.w,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.accentGold,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'GRANDMASTER',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20.sp,
          ),
          tooltip: 'Toggle Theme',
          onPressed: () {
            ref.read(themeProvider.notifier).state =
                isDark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.settings_outlined, size: 20.sp),
              tooltip: 'Settings',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
