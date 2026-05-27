import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../utils/board_utils.dart';

class AttackMap {
  static bool isAttacked({
    required Board board,
    required int targetRow,
    required int targetCol,
    required PieceColor attackerColor,
  }) {
    // Check for Pawn attacks
    final pawnDirection = attackerColor == PieceColor.white ? 1 : -1;
    // Attack from white pawn comes from targetRow + 1, black pawn from targetRow - 1
    if (_hasPiece(board, targetRow + pawnDirection, targetCol - 1, PieceType.pawn, attackerColor) ||
        _hasPiece(board, targetRow + pawnDirection, targetCol + 1, PieceType.pawn, attackerColor)) {
      return true;
    }

    // Check for Knight attacks
    final knightMoves = [
      (-2, -1), (-2, 1), (-1, -2), (-1, 2),
      (1, -2), (1, 2), (2, -1), (2, 1)
    ];
    for (var move in knightMoves) {
      if (_hasPiece(board, targetRow + move.$1, targetCol + move.$2, PieceType.knight, attackerColor)) {
        return true;
      }
    }

    // Check for King attacks (for adjacent squares)
    final kingMoves = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1)
    ];
    for (var move in kingMoves) {
      if (_hasPiece(board, targetRow + move.$1, targetCol + move.$2, PieceType.king, attackerColor)) {
        return true;
      }
    }

    // Check sliding attacks (Rook, Bishop, Queen)
    final bishopDirections = [(-1, -1), (-1, 1), (1, -1), (1, 1)];
    final rookDirections = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    if (_checkSliding(board, targetRow, targetCol, attackerColor, bishopDirections, [PieceType.bishop, PieceType.queen])) {
      return true;
    }

    if (_checkSliding(board, targetRow, targetCol, attackerColor, rookDirections, [PieceType.rook, PieceType.queen])) {
      return true;
    }

    return false;
  }

  static bool _hasPiece(Board board, int r, int c, PieceType type, PieceColor color) {
    if (!BoardUtils.insideBoard(r, c)) return false;
    final p = board.pieceAt(r, c);
    return p != null && p.type == type && p.color == color;
  }

  static bool _checkSliding(
      Board board, int row, int col, PieceColor attackerColor, List<(int, int)> directions, List<PieceType> types) {
    for (var dir in directions) {
      int r = row + dir.$1;
      int c = col + dir.$2;
      while (BoardUtils.insideBoard(r, c)) {
        final p = board.pieceAt(r, c);
        if (p != null) {
          if (p.color == attackerColor && types.contains(p.type)) {
            return true;
          }
          break; // Blocked by any piece
        }
        r += dir.$1;
        c += dir.$2;
      }
    }
    return false;
  }
}
