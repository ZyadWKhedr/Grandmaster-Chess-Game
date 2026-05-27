import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class GameReportDialog extends StatefulWidget {
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

  @override
  State<GameReportDialog> createState() => _GameReportDialogState();
}

class _GameReportDialogState extends State<GameReportDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isVsAi ? 1 : 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MoveRecord> _recordsFor(PieceColor color) =>
      widget.moveRecords.where((r) => r.player == color).toList();

  int _count(List<MoveRecord> records, MoveQuality q) =>
      records.where((r) => r.quality == q).length;

  double _accuracy(List<MoveRecord> records) {
    if (records.isEmpty) return 100.0;
    const weights = {
      MoveQuality.brilliant: 100,
      MoveQuality.good: 85,
      MoveQuality.inaccuracy: 60,
      MoveQuality.mistake: 35,
      MoveQuality.blunder: 10,
    };
    final total = records.fold<int>(
        0, (sum, r) => sum + (weights[r.quality] ?? 85));
    return total / records.length;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tabs = widget.isVsAi
        ? [Tab(text: 'your_report'.tr())]
        : [Tab(text: 'white_report'.tr()), Tab(text: 'black_report'.tr())];

    final colors = widget.isVsAi
        ? [widget.playerColor]
        : [PieceColor.white, PieceColor.black];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w, maxHeight: 520.h),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child: Row(
                      children: [
                        Icon(Icons.analytics_rounded,
                            color: scheme.primary, size: 24.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'report_card'.tr(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: scheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                  if (!widget.isVsAi)
                    TabBar(
                      controller: _tabController,
                      tabs: tabs,
                      labelColor: scheme.primary,
                      indicatorColor: scheme.primary,
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: colors
                    .map((c) => _PlayerReport(
                          records: _recordsFor(c),
                          accuracy: _accuracy(_recordsFor(c)),
                          countBrilliant: _count(_recordsFor(c), MoveQuality.brilliant),
                          countGood: _count(_recordsFor(c), MoveQuality.good),
                          countInaccuracy: _count(_recordsFor(c), MoveQuality.inaccuracy),
                          countMistake: _count(_recordsFor(c), MoveQuality.mistake),
                          countBlunder: _count(_recordsFor(c), MoveQuality.blunder),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerReport extends StatelessWidget {
  final List<MoveRecord> records;
  final double accuracy;
  final int countBrilliant;
  final int countGood;
  final int countInaccuracy;
  final int countMistake;
  final int countBlunder;

  const _PlayerReport({
    required this.records,
    required this.accuracy,
    required this.countBrilliant,
    required this.countGood,
    required this.countInaccuracy,
    required this.countMistake,
    required this.countBlunder,
  });

  @override
  Widget build(BuildContext context) {
    final totalMoves = records.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Accuracy Circle
          _AccuracyGauge(accuracy: accuracy),
          SizedBox(height: 16.h),
          Text(
            '$totalMoves ${'total_moves'.tr()}',
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 20.h),
          _StatRow(
            icon: Icons.auto_awesome,
            label: 'brilliant_moves'.tr(),
            count: countBrilliant,
            color: const Color(0xFF00BCD4),
          ),
          _StatRow(
            icon: Icons.thumb_up_rounded,
            label: 'good_moves'.tr(),
            count: countGood,
            color: Colors.green,
          ),
          _StatRow(
            icon: Icons.info_rounded,
            label: 'inaccuracies'.tr(),
            count: countInaccuracy,
            color: Colors.orange,
          ),
          _StatRow(
            icon: Icons.warning_rounded,
            label: 'mistakes'.tr(),
            count: countMistake,
            color: Colors.deepOrange,
          ),
          _StatRow(
            icon: Icons.dangerous_rounded,
            label: 'blunders'.tr(),
            count: countBlunder,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _AccuracyGauge extends StatelessWidget {
  final double accuracy;

  const _AccuracyGauge({required this.accuracy});

  Color get _color {
    if (accuracy >= 85) return Colors.green;
    if (accuracy >= 65) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100.w,
              height: 100.w,
              child: CircularProgressIndicator(
                value: accuracy / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
            Column(
              children: [
                Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: _color,
                  ),
                ),
                Text(
                  'accuracy'.tr(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
