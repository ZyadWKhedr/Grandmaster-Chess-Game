import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/chessboard_widget.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/evaluation_bar_widget.dart';

/// Board section enclosing the evaluation bar and responsive chessboard.
class GameBoardSection extends StatelessWidget {
  final GameState state;

  const GameBoardSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isFlipped = state.playerColor == PieceColor.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 8.h,
          width: double.infinity,
          child: EvaluationBarWidget(
            isHorizontal: true,
            isFlipped: isFlipped,
          ),
        ),
        SizedBox(height: 8.h),
        const AspectRatio(
          aspectRatio: 1,
          child: ChessBoardWidget(),
        ),
      ],
    );
  }
}
