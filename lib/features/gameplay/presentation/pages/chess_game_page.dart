import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/widgets/responsive_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/narrow_game_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/wide_game_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/services/game_coordinator.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/restart_confirmation_dialog.dart';

class ChessGamePage extends ConsumerWidget {
  const ChessGamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);
    final coordinator = ref.watch(gameCoordinatorProvider);

    ref.listen<GameState?>(chessGameProvider, (previous, next) {
      if (next?.pendingPromotion != null &&
          previous?.pendingPromotion == null) {
        coordinator.handlePromotion(context, next!);
      }
    });

    ref.listen<GameStatus?>(
      chessGameProvider.select((state) => state.status),
      (previous, next) {
        if (next != previous && previous != null) {
          coordinator.handleStatusChange(context, ref, state, next!);
        }
      },
    );

    final title = state.gameMode == GameMode.pvp
        ? 'local_multiplayer'.tr()
        : 'solo_vs_ai'.tr();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            fontSize: 19.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.moveRecords.isNotEmpty &&
              (state.status == GameStatus.checkmate ||
                  state.status == GameStatus.draw ||
                  state.status == GameStatus.timeout))
            IconButton(
              icon: Icon(Icons.analytics_rounded, size: 25.sp),
              tooltip: 'view_report'.tr(),
              onPressed: () => GameReportDialog.show(
                context,
                moveRecords: state.moveRecords,
                isVsAi: state.gameMode == GameMode.pva,
                playerColor: state.playerColor,
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, size: 26.sp),
            tooltip: 'restart_game'.tr(),
            onPressed: () => RestartConfirmationDialog.show(
              context,
              onConfirm: () => ref.read(chessGameProvider.notifier).initGame(
                state.gameMode,
                playerColor: state.playerColor,
                maxTime: state.maxTime,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          narrow: (_) => NarrowGameLayout(state: state),
          wide: (_) => WideGameLayout(state: state),
          breakpoint: 800,
        ),
      ),
    );
  }
}
