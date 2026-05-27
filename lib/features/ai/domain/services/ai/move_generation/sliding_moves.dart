import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

class SlidingMoves {
  static const bishopDirections = [
    (-1, -1),
    (-1, 1),
    (1, -1),
    (1, 1),
  ];

  static const rookDirections = [
    (-1, 0),
    (1, 0),
    (0, -1),
    (0, 1),
  ];

  List<Move> generateBishopMoves({
    required Board board,
    required int row,
    required int col,
    required Piece piece,
  }) {
    return _generateSliding(
      board,
      row,
      col,
      piece,
      bishopDirections,
    );
  }

  List<Move> generateRookMoves({
    required Board board,
    required int row,
    required int col,
    required Piece piece,
  }) {
    return _generateSliding(
      board,
      row,
      col,
      piece,
      rookDirections,
    );
  }

  List<Move> generateQueenMoves({
    required Board board,
    required int row,
    required int col,
    required Piece piece,
  }) {
    return _generateSliding(
      board,
      row,
      col,
      piece,
      [
        ...bishopDirections,
        ...rookDirections,
      ],
    );
  }

  List<Move> _generateSliding(
    Board board,
    int row,
    int col,
    Piece piece,
    List<(int, int)> directions,
  ) {
    final moves = <Move>[];

    for (final (dr, dc) in directions) {
      int r = row + dr;
      int c = col + dc;

      while (_insideBoard(r, c)) {
        final target = board.pieceAt(r, c);

        if (target == null) {
          moves.add(
            Move(
              fromRow: row,
              fromCol: col,
              toRow: r,
              toCol: c,
            ),
          );
        } else {
          if (target.color != piece.color) {
            moves.add(
              Move(
                fromRow: row,
                fromCol: col,
                toRow: r,
                toCol: c,
              ),
            );
          }

          break;
        }

        r += dr;
        c += dc;
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