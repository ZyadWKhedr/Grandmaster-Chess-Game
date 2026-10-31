import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'chess_square_widget.dart';

class ChessBoardWidget extends ConsumerWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);
    final notifier = ref.read(chessGameProvider.notifier);
    final isFlipped = state.playerColor == PieceColor.black;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF2E1C0C), width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemBuilder: (context, index) {
            final visualRow = index ~/ 8;
            final visualCol = index % 8;

            final row = isFlipped ? 7 - visualRow : visualRow;
            final col = isFlipped ? 7 - visualCol : visualCol;

            final piece = state.board.pieceAt(row, col);
            final isSelected =
                state.selected?.row == row && state.selected?.col == col;

            final isPossibleMove = state.possibleMoves.any(
              (m) => m.toRow == row && m.toCol == col,
            );

            final isLastMove =
                (state.lastMove?.fromRow == row &&
                    state.lastMove?.fromCol == col) ||
                (state.lastMove?.toRow == row && state.lastMove?.toCol == col);

            final isCheckedKing = piece?.type == PieceType.king &&
                piece?.color == state.turn &&
                (state.status == GameStatus.check ||
                    state.status == GameStatus.checkmate);

            return ChessSquareWidget(
              row: row,
              col: col,
              visualRow: visualRow,
              visualCol: visualCol,
              piece: piece,
              isSelected: isSelected,
              isPossibleMove: isPossibleMove,
              isLastMove: isLastMove,
              isCheckedKing: isCheckedKing,
              gameMode: state.gameMode,
              onTap: () {
                if (piece != null && piece.color == state.turn) {
                  notifier.selectSquare(row, col);
                } else if (state.selected != null) {
                  notifier.tryMove(row, col);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
