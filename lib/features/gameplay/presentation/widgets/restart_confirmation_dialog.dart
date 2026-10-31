import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_button.dart';
import 'package:grandmaster_chess/core/widgets/app_dialog.dart';

/// Modal dialog confirming intent to restart the ongoing game.
class RestartConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RestartConfirmationDialog({super.key, required this.onConfirm});

  static void show(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => RestartConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'restart_game'.tr(),
      icon: Icons.refresh_rounded,
      iconColor: const Color(0xFFF59E0B),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'are_you_sure_restart'.tr(),
            style: TextStyle(fontSize: 15.sp),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'cancel'.tr(),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'ok'.tr(),
                  variant: AppButtonVariant.danger,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

