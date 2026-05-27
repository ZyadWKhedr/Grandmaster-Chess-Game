import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';

import 'killer_moves.dart';
import 'history_heuristic.dart';

class MoveOrdering {
  final KillerMoves killer;
  final HistoryHeuristic history;

  MoveOrdering(this.killer, this.history);

  void sort(List<Move> moves, Board board, int depth) {
    moves.sort((a, b) {
      return _score(b, depth, board)
          .compareTo(_score(a, depth, board));
    });
  }

  int _score(Move m, int depth, Board board) {
    int score = 0;

    // captures first (MVV-LVA simplified)
    final target = board.pieceAt(m.toRow, m.toCol);
    if (target != null) {
      score += 10000;
    }

    // killer moves
    score += killer.score(depth, m);

    // history heuristic
    score += history.score(m);

    return score;
  }
}