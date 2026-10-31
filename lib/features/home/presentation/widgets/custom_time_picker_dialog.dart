import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_button.dart';
import 'package:grandmaster_chess/core/widgets/app_dialog.dart';

/// Modal dialog for inputting custom minutes.
class CustomTimePickerDialog extends StatelessWidget {
  const CustomTimePickerDialog({super.key});

  static Future<Duration?> show(BuildContext context) {
    return showDialog<Duration>(
      context: context,
      builder: (_) => const CustomTimePickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AppDialog(
      title: 'enter_custom_time'.tr(),
      icon: Icons.edit_calendar_rounded,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'minutes'.tr(),
                hintText: 'time_limit_hint'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'invalid_time'.tr();
                }
                final val = int.tryParse(value);
                if (val == null || val <= 0 || val > 180) {
                  return 'invalid_time'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'cancel'.tr(),
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppButton(
                    label: 'start'.tr(),
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final mins = int.parse(controller.text);
                        Navigator.pop(context, Duration(minutes: mins));
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

