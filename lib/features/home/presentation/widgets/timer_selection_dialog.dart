import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_dialog.dart';
import 'custom_time_picker_dialog.dart';
import 'timer_option_tile.dart';

class TimerSelectionDialog extends StatelessWidget {
  const TimerSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'select_game_time'.tr(),
      icon: Icons.timer_outlined,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TimerOptionTile(
                  label: 'no_limit'.tr(),
                  icon: Icons.all_inclusive_rounded,
                  onTap: () => Navigator.of(context).pop(Duration.zero),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TimerOptionTile(
                  label: 'ten_minutes'.tr(),
                  icon: Icons.timer_outlined,
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(minutes: 10)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TimerOptionTile(
                  label: 'five_minutes'.tr(),
                  icon: Icons.timer_outlined,
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(minutes: 5)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TimerOptionTile(
                  label: 'three_minutes'.tr(),
                  icon: Icons.timer_3_rounded,
                  onTap: () =>
                      Navigator.of(context).pop(const Duration(minutes: 3)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: TimerOptionTile(
              label: 'custom_time'.tr(),
              icon: Icons.edit_calendar_rounded,
              onTap: () async {
                final custom = await CustomTimePickerDialog.show(context);
                if (custom != null && context.mounted) {
                  Navigator.of(context).pop(custom);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
