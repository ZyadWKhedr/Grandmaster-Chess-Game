import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai/chess_ai_service.dart';

class EvaluationBarWidget extends ConsumerWidget {
  final bool isHorizontal;
  final bool isFlipped;
  
  const EvaluationBarWidget({
    super.key,
    this.isHorizontal = false,
    this.isFlipped = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);
    final evalScore = ChessAIService().evaluateBoardState(state.board, PieceColor.white);

    // Normalize the score to a percentage. 
    // Let's say +1000 is 100% white, -1000 is 100% black.
    // +0 is 50%.
    const maxEval = 1500.0;
    double percentage = (evalScore + maxEval) / (2 * maxEval);
    percentage = percentage.clamp(0.0, 1.0);

    // If board is flipped, invert the display so the bottom color matches the player's color
    if (isFlipped) {
      percentage = 1.0 - percentage;
    }

    final double width = isHorizontal ? double.infinity : 24.0;
    final double height = isHorizontal ? 24.0 : double.infinity;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          alignment: isHorizontal ? Alignment.centerLeft : Alignment.bottomCenter,
          children: [
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              widthFactor: isHorizontal ? percentage : 1.0,
              heightFactor: isHorizontal ? 1.0 : percentage,
              child: Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
