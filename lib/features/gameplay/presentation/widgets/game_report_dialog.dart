import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'player_report_view.dart';
import 'report_player_card.dart';

/// Modern chess game review summary dialog featuring head-to-head metrics
/// and empirical move accuracy breakdown.
class GameReportDialog extends StatelessWidget {
  final List<MoveRecord> moveRecords;
  final bool isVsAi;
  final PieceColor playerColor;

  const GameReportDialog({
    super.key,
    required this.moveRecords,
    required this.isVsAi,
    required this.playerColor,
  });

  static void show(
    BuildContext context, {
    required List<MoveRecord> moveRecords,
    required bool isVsAi,
    required PieceColor playerColor,
  }) {
    showDialog(
      context: context,
      builder: (_) => GameReportDialog(
        moveRecords: moveRecords,
        isVsAi: isVsAi,
        playerColor: playerColor,
      ),
    );
  }

  List<MoveRecord> _recordsFor(PieceColor color) =>
      moveRecords.where((r) => r.player == color).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final whiteRecords = _recordsFor(PieceColor.white);
    final blackRecords = _recordsFor(PieceColor.black);
    final whiteAcc = MoveRecord.accuracy(whiteRecords);
    final blackAcc = MoveRecord.accuracy(blackRecords);

    final whiteLabel = isVsAi
        ? (playerColor == PieceColor.white ? 'you'.tr() : 'ai_bot'.tr())
        : 'white'.tr();
    final blackLabel = isVsAi
        ? (playerColor == PieceColor.black ? 'you'.tr() : 'ai_bot'.tr())
        : 'black'.tr();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.r)),
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 2,
        initialIndex: (isVsAi && playerColor == PieceColor.black) ? 1 : 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 440.w, maxHeight: 580.h),
          child: Column(
            children: [
              Container(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 10.w, 8.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights_rounded, color: scheme.primary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'report_card'.tr(),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: scheme.outline.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ReportPlayerCard(
                              title: whiteLabel,
                              accuracy: whiteAcc,
                              isWhite: true,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: scheme.outline.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ReportPlayerCard(
                              title: blackLabel,
                              accuracy: blackAcc,
                              isWhite: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    TabBar(
                      labelColor: scheme.primary,
                      indicatorColor: scheme.primary,
                      indicatorWeight: 2.5,
                      labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                      tabs: [Tab(text: whiteLabel), Tab(text: blackLabel)],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PlayerReportView(records: whiteRecords),
                    PlayerReportView(records: blackRecords),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
