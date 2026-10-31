import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/constants/app_colors.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';

/// Renders an individual square on the chessboard with pieces, coordinates, and highlights.
class ChessSquareWidget extends StatelessWidget {
  final int row;
  final int col;
  final int visualRow;
  final int visualCol;
  final Piece? piece;
  final bool isSelected;
  final bool isPossibleMove;
  final bool isLastMove;
  final bool isCheckedKing;
  final GameMode gameMode;
  final VoidCallback onTap;

  const ChessSquareWidget({
    super.key,
    required this.row,
    required this.col,
    required this.visualRow,
    required this.visualCol,
    required this.piece,
    required this.isSelected,
    required this.isPossibleMove,
    required this.isLastMove,
    required this.isCheckedKing,
    required this.gameMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkSquare = (row + col) % 2 == 1;

    final baseColor = isDarkSquare
        ? AppColors.boardWoodDark
        : AppColors.boardWoodLight;

    final squareColor = isCheckedKing
        ? AppColors.squareCheck
        : isSelected
            ? AppColors.squareSelected
            : isLastMove
                ? AppColors.squareLastMove
                : baseColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: Stack(
          children: [
            if (visualCol == 0)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${8 - row}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isDarkSquare
                        ? AppColors.boardWoodLight
                        : AppColors.boardWoodDark,
                  ),
                ),
              ),
            if (visualRow == 7)
              Positioned(
                bottom: 1,
                right: 3,
                child: Text(
                  String.fromCharCode(97 + col).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: isDarkSquare
                        ? AppColors.boardWoodLight
                        : AppColors.boardWoodDark,
                  ),
                ),
              ),
            if (isPossibleMove)
              Center(
                child: Container(
                  width: piece == null ? 14.w : 32.w,
                  height: piece == null ? 14.h : 32.h,
                  decoration: BoxDecoration(
                    color: piece == null
                        ? Colors.black.withValues(alpha: 0.18)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: piece == null
                        ? null
                        : Border.all(
                            color: Colors.black.withValues(alpha: 0.25),
                            width: 3.5,
                          ),
                  ),
                ),
              ),
            Center(child: _buildPiece(piece, gameMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildPiece(Piece? piece, GameMode mode) {
    if (piece == null) return const SizedBox.shrink();

    final rendered = Padding(
      padding: EdgeInsets.all(4.w),
      child: piece.renderImage(),
    );
    if (mode == GameMode.pvp && piece.color == PieceColor.black) {
      return RotatedBox(quarterTurns: 2, child: rendered);
    }
    return rendered;
  }
}

