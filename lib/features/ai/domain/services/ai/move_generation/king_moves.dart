import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';
import '../utils/board_utils.dart';
import 'attack_map.dart';

class KingMoves {
  List<Move> generate({
    required SearchState state,
    required int row,
    required int col,
    required Piece piece,
  }) {
    final moves = <Move>[];
    final board = state.board;

    final directions = [
      (-1, -1), (-1, 0), (-1, 1),
      (0, -1),           (0, 1),
      (1, -1),  (1, 0),  (1, 1)
    ];

    for (var dir in directions) {
      int r = row + dir.$1;
      int c = col + dir.$2;

      if (BoardUtils.insideBoard(r, c)) {
        final target = board.pieceAt(r, c);
        if (target == null || target.color != piece.color) {
          moves.add(Move(fromRow: row, fromCol: col, toRow: r, toCol: c));
        }
      }
    }

    // Castling
    final enemyColor = piece.color == PieceColor.white ? PieceColor.black : PieceColor.white;
    if (piece.color == PieceColor.white && row == 7 && col == 4) {
      if (state.whiteKingSide) {
        if (board.pieceAt(7, 5) == null && board.pieceAt(7, 6) == null) {
          if (!AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 4, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 5, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 6, attackerColor: enemyColor)) {
            moves.add(const Move(fromRow: 7, fromCol: 4, toRow: 7, toCol: 6)); // Short castle
          }
        }
      }
      if (state.whiteQueenSide) {
        if (board.pieceAt(7, 3) == null && board.pieceAt(7, 2) == null && board.pieceAt(7, 1) == null) {
          if (!AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 4, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 3, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 7, targetCol: 2, attackerColor: enemyColor)) {
            moves.add(const Move(fromRow: 7, fromCol: 4, toRow: 7, toCol: 2)); // Long castle
          }
        }
      }
    } else if (piece.color == PieceColor.black && row == 0 && col == 4) {
      if (state.blackKingSide) {
        if (board.pieceAt(0, 5) == null && board.pieceAt(0, 6) == null) {
          if (!AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 4, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 5, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 6, attackerColor: enemyColor)) {
            moves.add(const Move(fromRow: 0, fromCol: 4, toRow: 0, toCol: 6)); // Short castle
          }
        }
      }
      if (state.blackQueenSide) {
        if (board.pieceAt(0, 3) == null && board.pieceAt(0, 2) == null && board.pieceAt(0, 1) == null) {
          if (!AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 4, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 3, attackerColor: enemyColor) &&
              !AttackMap.isAttacked(board: board, targetRow: 0, targetCol: 2, attackerColor: enemyColor)) {
            moves.add(const Move(fromRow: 0, fromCol: 4, toRow: 0, toCol: 2)); // Long castle
          }
        }
      }
    }

    return moves;
  }
}
