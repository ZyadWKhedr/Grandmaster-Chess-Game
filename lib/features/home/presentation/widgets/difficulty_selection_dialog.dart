import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_card.dart';
import 'package:grandmaster_chess/core/widgets/app_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';

class DifficultySelectionDialog extends StatelessWidget {
  const DifficultySelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'select_difficulty'.tr(),
      subtitle: 'challenging'.tr(),
      icon: Icons.psychology_rounded,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DifficultyTile(
            difficulty: Difficulty.beginner,
            label: 'beginner'.tr(),
            subtitle: 'easy'.tr(),
            icon: Icons.sentiment_satisfied_rounded,
            color: const Color(0xFF10B981),
          ),
          SizedBox(height: 10.h),
          _DifficultyTile(
            difficulty: Difficulty.intermediate,
            label: 'intermediate'.tr(),
            subtitle: 'medium'.tr(),
            icon: Icons.psychology_rounded,
            color: const Color(0xFFF59E0B),
          ),
          SizedBox(height: 10.h),
          _DifficultyTile(
            difficulty: Difficulty.master,
            label: 'master'.tr(),
            subtitle: 'hard'.tr(),
            icon: Icons.military_tech_rounded,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 10.h),
          _DifficultyTile(
            difficulty: Difficulty.grandmaster,
            label: 'grandmaster'.tr(),
            subtitle: 'extreme'.tr(),
            icon: Icons.workspace_premium_rounded,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final Difficulty difficulty;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _DifficultyTile({
    required this.difficulty,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(difficulty);
      },
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      borderColor: color.withValues(alpha: 0.25),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.withValues(alpha: 0.6),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
