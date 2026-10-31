import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import '../core/search_result.dart';
import '../core/search_state.dart';
import '../core/transposition_table.dart';
import '../core/zobrist.dart';
import '../evaluation/board_evaluator.dart';
import '../move_generation/move_generator.dart';
import '../utils/search_move_applier.dart';
import 'heuristics/history_heuristic.dart';
import 'heuristics/killer_moves.dart';
import 'heuristics/move_ordering.dart';
import 'heuristics/repetition_detector.dart';
import 'quiescence.dart';

/// Negamax search algorithm with Alpha-Beta pruning, Transposition Table,
/// Killer Move and History heuristics, and Quiescence search.
class Negamax {
  final MoveGenerator _moveGenerator = MoveGenerator();
  final BoardEvaluator _evaluator = BoardEvaluator();
  final KillerMoves _killerMoves = KillerMoves();
  final HistoryHeuristic _history = HistoryHeuristic();
  final RepetitionDetector _repetition = RepetitionDetector();
  final TranspositionTable _tt = TranspositionTable();
  final Zobrist _zobrist = Zobrist();
  late final MoveOrdering _moveOrdering;
  late final Quiescence _quiescence;

  Negamax() {
    _moveOrdering = MoveOrdering(_killerMoves, _history);
    _quiescence = Quiescence(_evaluator, _moveGenerator);
  }

  void resetSearchState() {
    _tt.clear();
    _repetition.clear();
  }

  SearchResult search({required SearchState state, required int depth}) {
    int bestScore = -999999;
    Move? bestMove;
    const int alpha = -999999;
    const int beta = 999999;

    final moves = _moveGenerator.generateMoves(state);
    _moveOrdering.sort(moves, state.board, depth);

    for (final move in moves) {
      final nextState = SearchMoveApplier.apply(state, move);
      final score = -_negamax(
        state: nextState,
        depth: depth - 1,
        alpha: -beta,
        beta: -alpha,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return SearchResult(bestMove: bestMove, evaluation: bestScore);
  }

  int _negamax({
    required SearchState state,
    required int depth,
    required int alpha,
    required int beta,
  }) {
    final key = _zobrist.computeKey(state);

    final ttEntry = _tt.get(key);
    if (ttEntry != null && ttEntry.depth >= depth) {
      switch (ttEntry.type) {
        case TTEntryType.exact:
          return ttEntry.score;
        case TTEntryType.lowerBound:
          if (ttEntry.score > alpha) alpha = ttEntry.score;
          break;
        case TTEntryType.upperBound:
          if (ttEntry.score < beta) beta = ttEntry.score;
          break;
      }
      if (alpha >= beta) return ttEntry.score;
    }

    final repetitionPenalty = _repetition.penalty(key);
    if (repetitionPenalty >= 100000) return 0;

    if (depth <= 0) {
      final score = _quiescence.search(state: state, alpha: alpha, beta: beta);
      return score - repetitionPenalty;
    }

    final moves = _moveGenerator.generateMoves(state);
    _moveOrdering.sort(moves, state.board, depth);

    if (moves.isEmpty) {
      return -999000 + (100 - depth);
    }

    int best = -999999;
    Move? bestMove;
    var entryType = TTEntryType.upperBound;

    _repetition.add(key);

    for (final move in moves) {
      final nextState = SearchMoveApplier.apply(state, move);
      final score = -_negamax(
        state: nextState,
        depth: depth - 1,
        alpha: -beta,
        beta: -alpha,
      );

      if (score > best) {
        best = score;
        bestMove = move;
      }

      if (score > alpha) {
        alpha = score;
        entryType = TTEntryType.exact;
      }

      if (alpha >= beta) {
        _killerMoves.add(depth, move);
        _history.add(move, depth);
        entryType = TTEntryType.lowerBound;
        break;
      }
    }

    _repetition.remove(key);

    _tt.put(
      key: key,
      depth: depth,
      score: best,
      type: entryType,
      bestMove: bestMove,
    );

    return best;
  }
}
