import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';

/// Circular gauge displaying player accuracy percentage with performance tier.
class ReportAccuracyGauge extends StatelessWidget {
  final double accuracy;

  const ReportAccuracyGauge({super.key, required this.accuracy});

  Color get _color {
    if (accuracy >= 85) return const Color(0xFF10B981);
    if (accuracy >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final tier = MoveRecord.performanceTier(accuracy);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 104.w,
              height: 104.w,
              child: CircularProgressIndicator(
                value: (accuracy / 100).clamp(0.0, 1.0),
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.grey.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: _color,
                  ),
                ),
                Text(
                  'accuracy'.tr(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _color.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            tier.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: _color,
            ),
          ),
        ),
      ],
    );
  }
}
