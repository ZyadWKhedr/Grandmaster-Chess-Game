import 'dart:math' as math;
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

enum MoveQuality { brilliant, good, inaccuracy, mistake, blunder }
enum GamePhase { opening, middlegame, endgame }

class MoveRecord {
  final Move move;
  final PieceColor player;
  final MoveQuality quality;
  final int evalBefore;
  final int evalAfter;
  final bool isSacrifice;

  const MoveRecord({
    required this.move,
    required this.player,
    required this.quality,
    required this.evalBefore,
    required this.evalAfter,
    this.isSacrifice = false,
  });

  int get delta {
    final whiteGain = evalAfter - evalBefore;
    return player == PieceColor.white ? whiteGain : -whiteGain;
  }

  // Classification with phase awareness
  static MoveQuality classify(
    int delta, {
    bool isSacrifice = false,
    GamePhase phase = GamePhase.middlegame,
  }) {
    if (isSacrifice && delta >= 0) return MoveQuality.brilliant;

    final (goodThreshold, inaccuracyThreshold, mistakeThreshold) =
        switch (phase) {
          GamePhase.opening => (-20, -80, -250),
          GamePhase.middlegame => (-30, -100, -300),
          GamePhase.endgame => (-50, -150, -350),
        };

    if (delta >= goodThreshold) return MoveQuality.good;
    if (delta >= inaccuracyThreshold) return MoveQuality.inaccuracy;
    if (delta >= mistakeThreshold) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }

  static GamePhase getGamePhase(int moveNumber) {
    if (moveNumber < 15) return GamePhase.opening;
    if (moveNumber < 40) return GamePhase.middlegame;
    return GamePhase.endgame;
  }

  static double winP(int centipawns) {
    final cp = centipawns.clamp(-1000, 1000).toDouble();
    return 100.0 / (1.0 + math.exp(-cp * 0.003682));
  }

  static double moveAccuracy(
    int evalBefore,
    int evalAfter,
    PieceColor player,
  ) {
    final cpBefore = player == PieceColor.white ? evalBefore : -evalBefore;
    final cpAfter = player == PieceColor.white ? evalAfter : -evalAfter;
    final wpBefore = winP(cpBefore);
    final wpAfter = winP(cpAfter);
    final wpLoss = (wpBefore - wpAfter).clamp(0.0, 100.0);
    return (103.1668 * math.exp(-0.04354 * wpLoss) - 3.1669).clamp(0.0, 100.0);
  }

  static double acpl(List<MoveRecord> records) {
    if (records.isEmpty) return 0;
    final totalLoss = records.fold<int>(
      0,
      (sum, r) => sum + math.max(0, -r.delta).toInt(),
    );
    return totalLoss / records.length;
  }

  static double accuracy(List<MoveRecord> records) {
    if (records.isEmpty) return 100.0;
    double total = 0;
    for (final r in records) {
      total += moveAccuracy(r.evalBefore, r.evalAfter, r.player);
    }
    return total / records.length;
  }

  Map<String, int>  getQualityBreakdown(List<MoveRecord> records) {
    final breakdown = {
      'brilliant': 0,
      'good': 0,
      'inaccuracy': 0,
      'mistake': 0,
      'blunder': 0,
    };

    for (final record in records) {
      breakdown[record.quality.name] =
          (breakdown[record.quality.name] ?? 0) + 1;
    }

    return breakdown;
  }
}