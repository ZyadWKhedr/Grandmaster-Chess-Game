import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';

enum TTEntryType { exact, lowerBound, upperBound }

class TTEntry {
  final int key;
  final int depth;
  final int score;
  final TTEntryType type;
  final Move? bestMove;

  const TTEntry({
    required this.key,
    required this.depth,
    required this.score,
    required this.type,
    this.bestMove,
  });
}

class TranspositionTable {
  // Using a fixed size table (e.g., 2^20 entries)
  static const int _tableSize = 1048576; // 1048576 = 0x100000
  static const int _tableMask = _tableSize - 1;

  final List<TTEntry?> _table = List.filled(_tableSize, null);

  void put({
    required int key,
    required int depth,
    required int score,
    required TTEntryType type,
    Move? bestMove,
  }) {
    final index = key & _tableMask;
    final existing = _table[index];

    // Always replace strategy or replace if depth is greater/equal
    if (existing == null || depth >= existing.depth) {
      _table[index] = TTEntry(
        key: key,
        depth: depth,
        score: score,
        type: type,
        bestMove: bestMove ?? existing?.bestMove, // Keep previous best move if none provided
      );
    }
  }

  TTEntry? get(int key) {
    final index = key & _tableMask;
    final entry = _table[index];

    if (entry != null && entry.key == key) {
      return entry;
    }
    return null;
  }

  void clear() {
    for (int i = 0; i < _tableSize; i++) {
      _table[i] = null;
    }
  }
}
