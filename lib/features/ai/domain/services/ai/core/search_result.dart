import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';

class SearchResult {
  final Move? bestMove;
  final int evaluation;

  const SearchResult({
    required this.bestMove,
    required this.evaluation,
  });
}