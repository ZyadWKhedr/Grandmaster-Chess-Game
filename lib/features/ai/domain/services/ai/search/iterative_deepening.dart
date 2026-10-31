import 'dart:core';
import 'package:grandmaster_chess/features/ai/domain/services/ai/core/search_result.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai/core/search_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'negamax.dart';

/// Iterative Deepening search controller with adaptive time management.
/// Guarantees bounded execution time and responsiveness across low-end
/// and high-end devices.
class IterativeDeepening {
  final Negamax _negamax = Negamax();

  SearchResult search({
    required SearchState state,
    required Difficulty difficulty,
  }) {
    _negamax.resetSearchState();

    final (maxDepth, timeLimitMs) = switch (difficulty) {
      Difficulty.beginner => (1, 300),
      Difficulty.intermediate => (2, 700),
      Difficulty.master => (3, 1400),
      Difficulty.grandmaster => (4, 2200),
    };

    SearchResult best = const SearchResult(
      bestMove: null,
      evaluation: 0,
    );

    final stopwatch = Stopwatch()..start();

    for (int depth = 1; depth <= maxDepth; depth++) {
      final currentIteration = _negamax.search(
        state: state,
        depth: depth,
      );

      if (currentIteration.bestMove != null) {
        best = currentIteration;
      }

      // Check time budget before starting a deeper, exponential depth
      if (stopwatch.elapsedMilliseconds >= timeLimitMs) {
        break;
      }
    }

    return best;
  }
}
