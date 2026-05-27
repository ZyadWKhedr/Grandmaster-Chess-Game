import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimerSelectionDialog extends StatelessWidget {
  const TimerSelectionDialog({super.key});

  Future<Duration?> _showCustomTimePicker(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('enter_custom_time'.tr()),
          content: Form(
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'invalid_time'.tr();
                    final val = int.tryParse(value);
                    if (val == null || val <= 0 || val > 180) return 'invalid_time'.tr();
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr().toUpperCase()),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final mins = int.parse(controller.text);
                  Navigator.pop(context, Duration(minutes: mins));
                }
              },
              child: Text('start'.tr().toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_game_time'.tr(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildOption(
                    context,
                    'no_limit'.tr(),
                    Icons.all_inclusive_rounded,
                    () => Navigator.of(context).pop(Duration.zero),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildOption(
                    context,
                    'ten_minutes'.tr(),
                    Icons.timer_outlined,
                    () => Navigator.of(context).pop(const Duration(minutes: 10)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildOption(
                    context,
                    'five_minutes'.tr(),
                    Icons.timer_outlined,
                    () => Navigator.of(context).pop(const Duration(minutes: 5)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildOption(
                    context,
                    'three_minutes'.tr(),
                    Icons.timer_3_rounded,
                    () => Navigator.of(context).pop(const Duration(minutes: 3)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: _buildOption(
                context,
                'custom_time'.tr(),
                Icons.edit_calendar_rounded,
                () async {
                  final customDuration = await _showCustomTimePicker(context);
                  if (customDuration != null && context.mounted) {
                    Navigator.of(context).pop(customDuration);
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr().toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
