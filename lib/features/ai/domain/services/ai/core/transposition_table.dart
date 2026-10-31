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

/// A cache for evaluated positions using Zobrist hashing.
/// Uses a compact size (65,536 entries) to prevent OOM on low-end devices
/// while providing rapid lookups and clearing.
class TranspositionTable {
  static const int _tableSize = 65536; // 64K entries (0x10000)
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

    if (existing == null || depth >= existing.depth) {
      _table[index] = TTEntry(
        key: key,
        depth: depth,
        score: score,
        type: type,
        bestMove: bestMove ?? existing?.bestMove,
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
    _table.fillRange(0, _tableSize, null);
  }
}
