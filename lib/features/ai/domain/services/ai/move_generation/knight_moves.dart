import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class KnightMoves {
  static const _offsets = [
    (-2, -1),
    (-2, 1),
    (-1, -2),
    (-1, 2),
    (1, -2),
    (1, 2),
    (2, -1),
    (2, 1),
  ];

  List<Move> generate({
    required Board board,
    required int row,
    required int col,
    required Piece piece,
  }) {
    final moves = <Move>[];

    for (final (dr, dc) in _offsets) {
      final newRow = row + dr;
      final newCol = col + dc;

      if (!_insideBoard(newRow, newCol)) continue;

      final target = board.pieceAt(newRow, newCol);

      if (target == null || target.color != piece.color) {
        moves.add(
          Move(
            fromRow: row,
            fromCol: col,
            toRow: newRow,
            toCol: newCol,
          ),
        );
      }
    }

    return moves;
  }

  bool _insideBoard(int row, int col) {
    return row >= 0 &&
        row < 8 &&
        col >= 0 &&
        col < 8;
  }
}