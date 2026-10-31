import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Clean pill badge used for status, turn indicators, advantage counters, and ratings.
class AppBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final badgeColor = color ??
        (isDark ? const Color(0xFF242938) : const Color(0xFFE2E8F0));
    final labelColor = textColor ??
        (isDark ? Colors.white : const Color(0xFF1E293B));

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13.sp, color: labelColor),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
