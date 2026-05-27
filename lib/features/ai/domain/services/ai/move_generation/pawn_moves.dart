import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import '../utils/board_utils.dart';

class PawnMoves {
  List<Move> generate({
    required Board board,
    required int row,
    required int col,
    required Piece piece,
    SquarePosition? enPassant,
  }) {
    final moves = <Move>[];
    final int dir = piece.color == PieceColor.white ? -1 : 1;
    final int startRow = piece.color == PieceColor.white ? 6 : 1;
    final int promotionRow = piece.color == PieceColor.white ? 0 : 7;

    void addPawnMove(int toRow, int toCol) {
      // Promotion: add one move per promotable piece type
      if (toRow == promotionRow) {
        for (final type in [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight,
        ]) {
          moves.add(Move(
            fromRow: row,
            fromCol: col,
            toRow: toRow,
            toCol: toCol,
            promotionType: type,
          ));
        }
      } else {
        moves.add(Move(fromRow: row, fromCol: col, toRow: toRow, toCol: toCol));
      }
    }

    // 1 step forward
    if (BoardUtils.insideBoard(row + dir, col) &&
        board.pieceAt(row + dir, col) == null) {
      addPawnMove(row + dir, col);

      // 2 steps forward from starting row
      if (row == startRow && board.pieceAt(row + dir * 2, col) == null) {
        moves.add(Move(
          fromRow: row,
          fromCol: col,
          toRow: row + dir * 2,
          toCol: col,
        ));
      }
    }

    // Diagonal captures
    for (int c in [col - 1, col + 1]) {
      if (BoardUtils.insideBoard(row + dir, c)) {
        final target = board.pieceAt(row + dir, c);
        if (target != null && target.color != piece.color) {
          addPawnMove(row + dir, c);
        }

        // En Passant
        if (enPassant != null &&
            enPassant.row == row + dir &&
            enPassant.col == c) {
          moves.add(Move(fromRow: row, fromCol: col, toRow: row + dir, toCol: c));
        }
      }
    }

    return moves;
  }
}
