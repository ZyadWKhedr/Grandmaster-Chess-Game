import 'package:flutter/material.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';

import '../../../gameplay/domain/entities/board.dart';

class MoveHistoryWidget extends StatelessWidget {
  final List<MoveRecord> moveRecords;
  final Move? lastMove;

  const MoveHistoryWidget({super.key, 
    required this.moveRecords,
    required this.lastMove,
  });

  @override
  Widget build(BuildContext context) {
    if (moveRecords.isEmpty) {
      return Center(
        child: Text('No moves yet'),
      );
    }

    return ListView.builder(
      itemCount: moveRecords.length,
      itemBuilder: (context, index) {
        final record = moveRecords[index];
        final isLastMove = record.move == lastMove;

        return Container(
          decoration: BoxDecoration(
            color: isLastMove ? Colors.amber.shade100 : null,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '${index + 1}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _moveToAlgebraic(record.move),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _buildQualityBadge(context, record.quality),
              SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  '${record.delta > 0 ? '+' : ''}${record.delta}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: record.delta > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQualityBadge(BuildContext context, MoveQuality quality) {
    final colors = {
      MoveQuality.brilliant: Colors.purple,
      MoveQuality.good: Colors.green,
      MoveQuality.inaccuracy: Colors.orange,
      MoveQuality.mistake: Colors.orange.shade700,
      MoveQuality.blunder: Colors.red,
    };

    // ignore: unused_local_variable
    const sizes = {
      MoveQuality.brilliant: '9',
      MoveQuality.good: '8',
      MoveQuality.inaccuracy: '8',
      MoveQuality.mistake: '8',
      MoveQuality.blunder: '9',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[quality]?.withOpacity(0.2),
        border: Border.all(color: colors[quality] ?? Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        quality.name[0].toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: colors[quality],
        ),
      ),
    );
  }

  String _moveToAlgebraic(Move move) {
    const files = 'abcdefgh';
    const ranks = '87654321';
    return '${files[move.fromCol]}${ranks[move.fromRow]}'
        '${files[move.toCol]}${ranks[move.toRow]}';
  }
}

class MoveCache {
  static const int _maxCacheSize = 256;
  final Map<String, List<Move>> _cache = {};

  String _generateKey(int boardHash, int row, int col) {
    return '${boardHash}_${row}_${col}';
  }

  List<Move>? get(Board board, int row, int col) {
    return _cache[_generateKey(board.hashCode, row, col)];
  }

  void set(Board board, int row, int col, List<Move> moves) {
    final key = _generateKey(board.hashCode, row, col);
    if (_cache.length >= _maxCacheSize) {
      // Remove least recently used (first entry)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = moves;
  }

  void clear() => _cache.clear();

  int get size => _cache.length;
}