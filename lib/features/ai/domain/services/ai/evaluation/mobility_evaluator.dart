import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import '../core/search_state.dart';

class MobilityEvaluator {
  // Mobility weights per piece type
  static const int _knightMobility = 4;
  static const int _bishopMobility = 3;
  static const int _rookMobility = 2;
  static const int _queenMobility = 1;

  int evaluate(SearchState state) {
    int whiteMobility = 0;
    int blackMobility = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = state.board.pieceAt(r, c);
        if (piece == null) continue;

        int mobility = 0;
        switch (piece.type) {
          case PieceType.knight:
            mobility = _knightMoves(state, r, c, piece.color);
            mobility *= _knightMobility;
            break;
          case PieceType.bishop:
            mobility = _slidingMoves(state, r, c, piece.color, true, false);
            mobility *= _bishopMobility;
            break;
          case PieceType.rook:
            mobility = _slidingMoves(state, r, c, piece.color, false, true);
            mobility *= _rookMobility;
            break;
          case PieceType.queen:
            mobility = _slidingMoves(state, r, c, piece.color, true, true);
            mobility *= _queenMobility;
            break;
          case PieceType.pawn:
          case PieceType.king:
            // Often excluded from mobility calculations in simple evals
            continue;
        }

        if (piece.color == PieceColor.white) {
          whiteMobility += mobility;
        } else {
          blackMobility += mobility;
        }
      }
    }

    return whiteMobility - blackMobility;
  }

  int _knightMoves(SearchState state, int r, int c, PieceColor color) {
    const offsets = [
      (-2, -1), (-2, 1), (-1, -2), (-1, 2),
      (1, -2),  (1, 2),  (2, -1),  (2, 1)
    ];
    int count = 0;
    for (final offset in offsets) {
      final nr = r + offset.$1;
      final nc = c + offset.$2;
      if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
        final target = state.board.pieceAt(nr, nc);
        if (target == null || target.color != color) {
          count++;
        }
      }
    }
    return count;
  }

  int _slidingMoves(SearchState state, int r, int c, PieceColor color, bool diag, bool straight) {
    int count = 0;
    final dirs = <(int, int)>[];
    if (straight) {
      dirs.addAll([(-1, 0), (1, 0), (0, -1), (0, 1)]);
    }
    if (diag) {
      dirs.addAll([(-1, -1), (-1, 1), (1, -1), (1, 1)]);
    }

    for (final dir in dirs) {
      int nr = r + dir.$1;
      int nc = c + dir.$2;
      while (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
        final target = state.board.pieceAt(nr, nc);
        if (target == null) {
          count++;
        } else {
          if (target.color != color) count++;
          break;
        }
        nr += dir.$1;
        nc += dir.$2;
      }
    }
    return count;
  }
}
