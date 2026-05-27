// home_actions_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/core/providers/ad_provider.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/chess_game_page.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/difficulty_selection_dialog.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/side_selection_dialog.dart';
import 'package:grandmaster_chess/features/home/presentation/widgets/timer_selection_dialog.dart';

final homeActionsProvider = Provider<HomeActionsService>((ref) {
  ref.read(interstitialAdProvider);

  return HomeActionsService(ref);
});

class HomeActionsService {
  final Ref ref;

  HomeActionsService(this.ref);

  Future<void> startAiGame(BuildContext context) async {
    final selectedColor = await showDialog<PieceColor>(
      context: context,
      builder: (_) => const SideSelectionDialog(),
    );

    if (selectedColor == null || !context.mounted) return;

    final selectedDifficulty = await showDialog<Difficulty>(
      context: context,
      builder: (_) => const DifficultySelectionDialog(),
    );

    if (selectedDifficulty == null || !context.mounted) return;

    ref
        .read(chessGameProvider.notifier)
        .initGame(
          GameMode.pva,
          playerColor: selectedColor,
          difficulty: selectedDifficulty,
        );

    _navigateToGame(context);
  }

  Future<void> startLocalGame(BuildContext context) async {
    final result = await showDialog<Duration?>(
      context: context,
      builder: (_) => const TimerSelectionDialog(),
    );

    if (result == null || !context.mounted) return;

    final selectedDuration =
        result == Duration.zero ? null : result;

    ref
        .read(chessGameProvider.notifier)
        .initGame(
          GameMode.pvp,
          maxTime: selectedDuration,
        );

    _navigateToGame(context);
  }

  void _navigateToGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChessGamePage(),
      ),
    );
  }
}