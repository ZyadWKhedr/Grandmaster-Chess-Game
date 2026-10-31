import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/core/widgets/app_card.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/game_enums.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/home/presentation/providers/match_setup_provider.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/home_segmented_control.dart';

/// In-place game configuration panel inspired by modern chess engine frontends.
class HomeMatchSetupSection extends ConsumerWidget {
  const HomeMatchSetupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(matchSetupProvider);
    final notifier = ref.read(matchSetupProvider.notifier);

    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('GAME MODE'),
          SizedBox(height: 8.h),
          HomeSegmentedControl<GameMode>(
            items: const [
              SegmentItem(
                value: GameMode.pva,
                label: 'Solo vs AI',
                icon: Icons.smart_toy_rounded,
              ),
              SegmentItem(
                value: GameMode.pvp,
                label: 'Pass & Play',
                icon: Icons.people_alt_rounded,
              ),
            ],
            selectedValue: setup.mode,
            onValueChanged: notifier.setMode,
          ),
          if (setup.mode == GameMode.pva) ...[
            SizedBox(height: 14.h),
            _buildSectionLabel('AI DIFFICULTY'),
            SizedBox(height: 8.h),
            HomeSegmentedControl<Difficulty>(
              items: const [
                SegmentItem(value: Difficulty.beginner, label: 'Novice'),
                SegmentItem(value: Difficulty.intermediate, label: 'Casual'),
                SegmentItem(value: Difficulty.master, label: 'Master'),
                SegmentItem(value: Difficulty.grandmaster, label: 'GM'),
              ],
              selectedValue: setup.difficulty,
              onValueChanged: notifier.setDifficulty,
            ),
            SizedBox(height: 14.h),
            _buildSectionLabel('PLAY AS'),
            SizedBox(height: 8.h),
            _buildSideSelector(setup, notifier),
          ],
          SizedBox(height: 14.h),
          _buildSectionLabel('TIME CONTROL'),
          SizedBox(height: 8.h),
          _buildTimeControlSelector(setup, notifier),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.darkTextSecondary,
      ),
    );
  }

  Widget _buildSideSelector(MatchSetupState setup, MatchSetupNotifier notifier) {
    final selectedKey = setup.isRandomSide
        ? 'random'
        : (setup.playerColor == PieceColor.white ? 'white' : 'black');

    return HomeSegmentedControl<String>(
      items: const [
        SegmentItem(value: 'white', label: 'White ♔'),
        SegmentItem(value: 'random', label: 'Random 🎲'),
        SegmentItem(value: 'black', label: 'Black ♚'),
      ],
      selectedValue: selectedKey,
      onValueChanged: (val) {
        if (val == 'random') {
          notifier.setSide(PieceColor.white, isRandom: true);
        } else if (val == 'white') {
          notifier.setSide(PieceColor.white, isRandom: false);
        } else {
          notifier.setSide(PieceColor.black, isRandom: false);
        }
      },
    );
  }

  Widget _buildTimeControlSelector(
    MatchSetupState setup,
    MatchSetupNotifier notifier,
  ) {
    final currentMinutes = setup.timeLimit?.inMinutes ?? 0;

    return HomeSegmentedControl<int>(
      items: const [
        SegmentItem(value: 0, label: 'Casual'),
        SegmentItem(value: 3, label: '3 min'),
        SegmentItem(value: 5, label: '5 min'),
        SegmentItem(value: 10, label: '10 min'),
      ],
      selectedValue: currentMinutes,
      onValueChanged: (minutes) {
        notifier.setTimeLimit(minutes == 0 ? null : Duration(minutes: minutes));
      },
    );
  }
}
