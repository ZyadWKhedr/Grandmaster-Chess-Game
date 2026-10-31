import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/core/widgets/app_card.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/chess_game_page.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/home/presentation/providers/match_setup_provider.dart';

/// Instant quick-launch presets for popular chess time formats.
class HomeTimePresetsSection extends ConsumerWidget {
  const HomeTimePresetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void launchPreset(Duration? duration) {
      final setup = ref.read(matchSetupProvider);
      ref.read(chessGameProvider.notifier).initGame(
        setup.mode,
        playerColor: setup.resolvedColor,
        difficulty: setup.difficulty,
        maxTime: duration,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChessGamePage()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 420;

        final tiles = [
          _PresetTile(
            title: '10 min',
            subtitle: 'Rapid',
            icon: Icons.bolt_rounded,
            iconColor: AppColors.accentGold,
            onTap: () => launchPreset(const Duration(minutes: 10)),
          ),
          _PresetTile(
            title: '5 min',
            subtitle: 'Blitz',
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFFEF4444),
            onTap: () => launchPreset(const Duration(minutes: 5)),
          ),
          _PresetTile(
            title: '3 min',
            subtitle: 'Bullet',
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFF38BDF8),
            onTap: () => launchPreset(const Duration(minutes: 3)),
          ),
          _PresetTile(
            title: 'Casual',
            subtitle: 'No Clock',
            icon: Icons.all_inclusive_rounded,
            iconColor: AppColors.primaryGreen,
            onTap: () => launchPreset(null),
          ),
        ];

        if (isWide) {
          return Row(
            children: tiles
                .map((t) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: t,
                      ),
                    ))
                .toList(),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: tiles[0]),
                SizedBox(width: 8.w),
                Expanded(child: tiles[1]),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(child: tiles[2]),
                SizedBox(width: 8.w),
                Expanded(child: tiles[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PresetTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _PresetTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 16.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
