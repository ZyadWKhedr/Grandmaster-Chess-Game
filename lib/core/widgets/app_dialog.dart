import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Modal dialog wrapper providing standard padding, rounded frame, and title bar.
class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;
  final List<Widget>? actions;
  final double maxWidth;

  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.child,
    this.actions,
    this.maxWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth.w),
          child: Container(
            padding: EdgeInsets.all(22.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161923) : Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: (iconColor ?? theme.colorScheme.primary)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 24.sp,
                          color: iconColor ?? theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 14.w),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                child,
                if (actions != null && actions!.isNotEmpty) ...[
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

