import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';

class SegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Refined segmented picker with haptic feedback and fluid selection states.
class HomeSegmentedControl<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final double? height;

  const HomeSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackBg = isDark
        ? const Color(0xFF16181F)
        : const Color(0xFFEDF0F5);
    final trackBorder = isDark
        ? const Color(0xFF282C37)
        : const Color(0xFFD6DBE5);

    return Container(
      height: height ?? 44.h,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: trackBorder, width: 1),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          return Expanded(
            child: _SegmentTile<T>(
              item: item,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onValueChanged(item.value);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SegmentTile<T> extends StatelessWidget {
  final SegmentItem<T> item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SegmentTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.22)
        : Colors.white;
    final activeBorder = isDark
        ? AppColors.primaryGreen.withValues(alpha: 0.5)
        : AppColors.primaryGreen.withValues(alpha: 0.4);

    final textColor = isSelected
        ? (isDark ? AppColors.primaryGreenLight : AppColors.primaryGreenDark)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          border: isSelected
              ? Border.all(color: activeBorder, width: 1)
              : null,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 14.sp,
                  color: textColor,
                ),
                SizedBox(width: 4.w),
              ],
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
