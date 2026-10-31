import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/game_enums.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';

export 'package:grandmaster_chess/features/gameplay/domain/entities/game_enums.dart';

class GameState {
  final Board board;
  final PieceColor turn;
  final SquarePosition? selected;
  final List<Move> possibleMoves;
  final List<Piece> whiteCaptured;
  final List<Piece> blackCaptured;
  final GameMode gameMode;
  final bool isThinking;
  final GameStatus status;
  final Move? lastMove;
  final Move? pendingPromotion;
  final List<String> moveHistory;
  final int halfMoveClock;
  final Map<String, int> positionCounts;

  final PieceColor playerColor;
  final Difficulty aiDifficulty;
  final String? aiMessage;

  final SquarePosition? enPassantTarget;
  final bool canCastleWhiteKingSide;
  final bool canCastleWhiteQueenSide;
  final bool canCastleBlackKingSide;
  final bool canCastleBlackQueenSide;
  final Duration? whiteTime;
  final Duration? blackTime;
  final Duration? maxTime;
  final List<MoveRecord> moveRecords;

  const GameState({
    required this.board,
    required this.turn,
    this.selected,
    required this.possibleMoves,
    required this.whiteCaptured,
    required this.blackCaptured,
    required this.gameMode,
    this.playerColor = PieceColor.white,
    this.aiDifficulty = Difficulty.intermediate,
    this.aiMessage,
    this.isThinking = false,
    this.status = GameStatus.ongoing,
    this.lastMove,
    this.pendingPromotion,
    this.moveHistory = const [],
    this.halfMoveClock = 0,
    this.positionCounts = const {},
    this.enPassantTarget,
    this.canCastleWhiteKingSide = true,
    this.canCastleWhiteQueenSide = true,
    this.canCastleBlackKingSide = true,
    this.canCastleBlackQueenSide = true,
    this.whiteTime,
    this.blackTime,
    this.maxTime,
    this.moveRecords = const [],
  });

  factory GameState.initial({
    GameMode mode = GameMode.pvp,
    PieceColor playerColor = PieceColor.white,
    Difficulty difficulty = Difficulty.intermediate,
    Duration? maxTime,
  }) {
    return GameState(
      board: Board.initial(),
      turn: PieceColor.white,
      selected: null,
      possibleMoves: const [],
      whiteCaptured: const [],
      blackCaptured: const [],
      gameMode: mode,
      playerColor: playerColor,
      aiDifficulty: difficulty,
      status: GameStatus.ongoing,
      whiteTime: maxTime,
      blackTime: maxTime,
      maxTime: maxTime,
    );
  }

  static String generatePositionKey(GameState state) {
    final buffer = StringBuffer();
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = state.board.pieceAt(r, c);
        if (p == null) {
          buffer.write('.');
        } else {
          final char = p.type.name[0];
          buffer.write(
            p.color == PieceColor.white ? char.toUpperCase() : char.toLowerCase(),
          );
        }
      }
    }
    buffer.write(state.turn == PieceColor.white ? 'w' : 'b');
    buffer.write(state.canCastleWhiteKingSide ? 'K' : '-');
    buffer.write(state.canCastleWhiteQueenSide ? 'Q' : '-');
    buffer.write(state.canCastleBlackKingSide ? 'k' : '-');
    buffer.write(state.canCastleBlackQueenSide ? 'q' : '-');
    if (state.enPassantTarget != null) {
      buffer.write('${state.enPassantTarget!.row},${state.enPassantTarget!.col}');
    } else {
      buffer.write('-');
    }
    return buffer.toString();
  }

  GameState copyWith({
    Board? board,
    PieceColor? turn,
    SquarePosition? Function()? selected,
    List<Move>? possibleMoves,
    List<Piece>? whiteCaptured,
    List<Piece>? blackCaptured,
    GameMode? gameMode,
    bool? isThinking,
    GameStatus? status,
    Move? lastMove,
    Move? Function()? pendingPromotion,
    SquarePosition? Function()? enPassantTarget,
    bool? canCastleWhiteKingSide,
    bool? canCastleWhiteQueenSide,
    bool? canCastleBlackKingSide,
    bool? canCastleBlackQueenSide,
    PieceColor? playerColor,
    Difficulty? aiDifficulty,
    String? aiMessage,
    bool clearMessage = false,
    List<String>? moveHistory,
    int? halfMoveClock,
    Map<String, int>? positionCounts,
    Duration? whiteTime,
    Duration? blackTime,
    Duration? maxTime,
    List<MoveRecord>? moveRecords,
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      selected: selected != null ? selected() : this.selected,
      possibleMoves: possibleMoves ?? this.possibleMoves,
      whiteCaptured: whiteCaptured ?? this.whiteCaptured,
      blackCaptured: blackCaptured ?? this.blackCaptured,
      gameMode: gameMode ?? this.gameMode,
      isThinking: isThinking ?? this.isThinking,
      status: status ?? this.status,
      lastMove: lastMove ?? this.lastMove,
      pendingPromotion: pendingPromotion != null
          ? pendingPromotion()
          : this.pendingPromotion,
      enPassantTarget: enPassantTarget != null
          ? enPassantTarget()
          : this.enPassantTarget,
      canCastleWhiteKingSide:
          canCastleWhiteKingSide ?? this.canCastleWhiteKingSide,
      canCastleWhiteQueenSide:
          canCastleWhiteQueenSide ?? this.canCastleWhiteQueenSide,
      canCastleBlackKingSide:
          canCastleBlackKingSide ?? this.canCastleBlackKingSide,
      canCastleBlackQueenSide:
          canCastleBlackQueenSide ?? this.canCastleBlackQueenSide,
      playerColor: playerColor ?? this.playerColor,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      aiMessage: clearMessage ? null : (aiMessage ?? this.aiMessage),
      moveHistory: moveHistory ?? this.moveHistory,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      positionCounts: positionCounts ?? this.positionCounts,
      whiteTime: whiteTime ?? this.whiteTime,
      blackTime: blackTime ?? this.blackTime,
      maxTime: maxTime ?? this.maxTime,
      moveRecords: moveRecords ?? this.moveRecords,
    );
  }
}
