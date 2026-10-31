import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

/// Reusable core button with grandmaster aesthetics and tactile haptics.
class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (bgColor, fgColor, borderColor) = switch (variant) {
      AppButtonVariant.primary => (
          theme.colorScheme.primary,
          theme.colorScheme.onPrimary,
          Colors.transparent
        ),
      AppButtonVariant.secondary => (
          isDark ? const Color(0xFF25293A) : const Color(0xFFEEF2F6),
          isDark ? Colors.white : const Color(0xFF1E293B),
          Colors.transparent
        ),
      AppButtonVariant.outline => (
          Colors.transparent,
          isDark ? Colors.white70 : const Color(0xFF334155),
          isDark ? Colors.white24 : Colors.black12
        ),
      AppButtonVariant.danger => (
          const Color(0xFFDC2626),
          Colors.white,
          Colors.transparent
        ),
    };

    return SizedBox(
      width: width,
      height: height ?? 52.h,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: (onPressed == null || isLoading)
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, size: 20.sp, color: fgColor),
                    SizedBox(width: 10.w),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fgColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
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

