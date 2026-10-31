import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/app_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'side_option_card.dart';

class SideSelectionDialog extends StatelessWidget {
  const SideSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'choose_side'.tr(),
      subtitle: 'play_as'.tr(),
      icon: Icons.shield_rounded,
      child: Row(
        children: [
          Expanded(
            child: SideOptionCard(
              color: PieceColor.white,
              label: 'white'.tr(),
              onTap: () => Navigator.of(context).pop(PieceColor.white),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: SideOptionCard(
              color: PieceColor.black,
              label: 'black'.tr(),
              onTap: () => Navigator.of(context).pop(PieceColor.black),
            ),
          ),
        ],
      ),
    );
  }
}
