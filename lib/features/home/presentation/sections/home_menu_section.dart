import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_button.dart';
import 'package:grandmaster_chess/features/home/presentation/providers/home_actions_provider.dart';

/// Primary navigation menu on the Home screen.
class HomeMenuSection extends ConsumerWidget {
  const HomeMenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(homeActionsProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 320.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'play_vs_computer'.tr(),
            icon: Icons.smart_toy_rounded,
            variant: AppButtonVariant.primary,
            width: double.infinity,
            height: 56.h,
            onPressed: () => actions.startAiGame(context),
          ),
          SizedBox(height: 14.h),
          AppButton(
            label: 'play_vs_friend'.tr(),
            icon: Icons.people_alt_rounded,
            variant: AppButtonVariant.secondary,
            width: double.infinity,
            height: 56.h,
            onPressed: () => actions.startLocalGame(context),
          ),
        ],
      ),
    );
  }
}

