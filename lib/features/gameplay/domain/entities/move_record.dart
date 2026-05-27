import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';

enum MoveQuality { brilliant, good, inaccuracy, mistake, blunder }

class MoveRecord {
  final Move move;
  final PieceColor player;
  final MoveQuality quality;
  final int evalBefore; // centipawns from white's perspective
  final int evalAfter;

  const MoveRecord({
    required this.move,
    required this.player,
    required this.quality,
    required this.evalBefore,
    required this.evalAfter,
  });

  /// Score delta from the moving player's perspective
  int get delta {
    final whiteGain = evalAfter - evalBefore;
    return player == PieceColor.white ? whiteGain : -whiteGain;
  }

  static MoveQuality classify(int delta) {
    if (delta >= 150) return MoveQuality.brilliant;
    if (delta >= -49) return MoveQuality.good;
    if (delta >= -99) return MoveQuality.inaccuracy;
    if (delta >= -199) return MoveQuality.mistake;
    return MoveQuality.blunder;
  }
}
