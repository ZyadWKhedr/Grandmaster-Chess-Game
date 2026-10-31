import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'report_accuracy_gauge.dart';
import 'report_stat_row.dart';

/// Single player analysis view displaying empirical accuracy and move classification breakdown.
class PlayerReportView extends StatelessWidget {
  final List<MoveRecord> records;

  const PlayerReportView({super.key, required this.records});

  int _count(MoveQuality q) => records.where((r) => r.quality == q).length;

  @override
  Widget build(BuildContext context) {
    final accuracy = MoveRecord.accuracy(records);
    final acpl = MoveRecord.acpl(records);
    final total = records.length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          ReportAccuracyGauge(accuracy: accuracy),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildChip(
                context,
                icon: Icons.tag_rounded,
                text: '$total ${'total_moves'.tr()}',
              ),
              _buildChip(
                context,
                icon: Icons.trending_down_rounded,
                text: '${acpl.toStringAsFixed(0)} ACPL',
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ReportStatRow(
            icon: Icons.auto_awesome_rounded,
            label: 'brilliant_moves'.tr(),
            symbol: '!!',
            count: _count(MoveQuality.brilliant),
            total: total,
            color: const Color(0xFF06B6D4),
          ),
          ReportStatRow(
            icon: Icons.thumb_up_rounded,
            label: 'good_moves'.tr(),
            symbol: '!',
            count: _count(MoveQuality.good),
            total: total,
            color: const Color(0xFF10B981),
          ),
          ReportStatRow(
            icon: Icons.help_outline_rounded,
            label: 'inaccuracies'.tr(),
            symbol: '?!',
            count: _count(MoveQuality.inaccuracy),
            total: total,
            color: const Color(0xFFF59E0B),
          ),
          ReportStatRow(
            icon: Icons.warning_amber_rounded,
            label: 'mistakes'.tr(),
            symbol: '?',
            count: _count(MoveQuality.mistake),
            total: total,
            color: const Color(0xFFF97316),
          ),
          ReportStatRow(
            icon: Icons.close_rounded,
            label: 'blunders'.tr(),
            symbol: '??',
            count: _count(MoveQuality.blunder),
            total: total,
            color: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
