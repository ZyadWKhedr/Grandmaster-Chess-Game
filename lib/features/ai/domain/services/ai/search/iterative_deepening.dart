import 'package:grandmaster_chess/features/ai/domain/services/ai/core/search_result.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai/core/search_state.dart';

import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'negamax.dart';

class IterativeDeepening {
  final Negamax _negamax = Negamax();

  SearchResult search({
    required SearchState state,
    required Difficulty difficulty,
  }) {
    int maxDepth = switch (difficulty) {
      Difficulty.beginner => 1,
      Difficulty.intermediate => 2,
      Difficulty.master => 3,
      Difficulty.grandmaster => 4,
    };

    SearchResult best = const SearchResult(
      bestMove: null,
      evaluation: 0,
    );

    for (int depth = 1; depth <= maxDepth; depth++) {
      best = _negamax.search(
        state: state,
        depth: depth,
      );
    }

    return best;
  }
}