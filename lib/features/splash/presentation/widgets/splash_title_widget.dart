import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashTitleWidget extends StatelessWidget {
  const SplashTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeIn,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Grandmaster Chess',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'MASTER THE GAME',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              letterSpacing: 3.5,
            ),
          ),
        ],
      ),
    );
  }
}
