import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import 'package:grandmaster_chess/features/gameplay/domain/services/move_validator.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai/chess_ai_service.dart';
import 'package:grandmaster_chess/features/ai/domain/services/ai_trash_talk_service.dart';



class ChessGameService {
  final MoveValidator _validator;
  final ChessAIService _aiService;
  final AiTrashTalkService _trashTalkService;

  ChessGameService(this._validator, this._aiService, this._trashTalkService);

  List<Move> generateMoves(GameState state, int row, int col) {
    final moves = <Move>[];
    final piece = state.board.pieceAt(row, col);
    if (piece == null) return moves;

    final isWhite = piece.color == PieceColor.white;
    final canCastleKing = isWhite
        ? state.canCastleWhiteKingSide
        : state.canCastleBlackKingSide;
    final canCastleQueen = isWhite
        ? state.canCastleWhiteQueenSide
        : state.canCastleBlackQueenSide;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final move = Move(fromRow: row, fromCol: col, toRow: r, toCol: c);
        if (_validator.isValidMove(
          board: state.board,
          move: move,
          enPassantTarget: state.enPassantTarget,
          canCastleKingSide: canCastleKing,
          canCastleQueenSide: canCastleQueen,
        )) {
          moves.add(move);
        }
      }
    }
    return moves;
  }

  GameState applyMove(GameState state, Move move) {
    // Capture evaluation BEFORE the move for move analysis.
    final evalBefore = _aiService.evaluateBoardStateWithRights(
      state.board,
      state.turn,  // FIX: Use actual moving player
      canCastleWKS: state.canCastleWhiteKingSide,
      canCastleWQS: state.canCastleWhiteQueenSide,
      canCastleBKS: state.canCastleBlackKingSide,
      canCastleBQS: state.canCastleBlackQueenSide,
      enPassantTarget: state.enPassantTarget,
    );
    final movingPlayer = state.turn;

    final newSquares = state.board.squares
        .map((row) => List<Piece?>.from(row))
        .toList();
    final movingPiece = newSquares[move.fromRow][move.fromCol];
    final capturedPiece = newSquares[move.toRow][move.toCol];

    if (movingPiece == null) return state;

    // Detect sacrifice: moving piece is more valuable than captured piece
    final bool isSacrifice = _isSacrifice(movingPiece, capturedPiece);

    final newWhiteCaptured = List<Piece>.from(state.whiteCaptured);
    final newBlackCaptured = List<Piece>.from(state.blackCaptured);

    // Standard Capture
    if (capturedPiece != null) {
      if (state.turn == PieceColor.white) {
        newWhiteCaptured.add(capturedPiece);
      } else {
        newBlackCaptured.add(capturedPiece);
      }
    }

    // --- EN PASSANT CAPTURE (FIXED) ---
    if (movingPiece.type == PieceType.pawn &&
        state.enPassantTarget?.row == move.toRow &&
        state.enPassantTarget?.col == move.toCol) {
      // The captured pawn is one rank behind our destination
      final capturedPawnRow = movingPiece.color == PieceColor.white
          ? state.enPassantTarget!.row + 1  // White pawns move down
          : state.enPassantTarget!.row - 1; // Black pawns move up
      final capturedPawnCol = state.enPassantTarget!.col;
      
      final extraCapture = newSquares[capturedPawnRow][capturedPawnCol];
      if (extraCapture != null && extraCapture.type == PieceType.pawn) {
        if (state.turn == PieceColor.white) {
          newWhiteCaptured.add(extraCapture);
        } else {
          newBlackCaptured.add(extraCapture);
        }
        newSquares[capturedPawnRow][capturedPawnCol] = null;
      }
    }

    // --- CASTLING ROOK MOVE ---
    if (movingPiece.type == PieceType.king) {
      if (move.toCol - move.fromCol == 2) {
        // King-side castle
        final rook = newSquares[move.fromRow][7];
        newSquares[move.fromRow][5] = rook;
        newSquares[move.fromRow][7] = null;
      } else if (move.toCol - move.fromCol == -2) {
        // Queen-side castle
        final rook = newSquares[move.fromRow][0];
        newSquares[move.fromRow][3] = rook;
        newSquares[move.fromRow][0] = null;
      }
    }

    // Update positions
    newSquares[move.toRow][move.toCol] = movingPiece;
    newSquares[move.fromRow][move.fromCol] = null;

    // --- EN PASSANT TARGET ---
    SquarePosition? nextEnPassantTarget;
    if (movingPiece.type == PieceType.pawn &&
        (move.toRow - move.fromRow).abs() == 2) {
      nextEnPassantTarget = SquarePosition(
        (move.fromRow + move.toRow) ~/ 2,
        move.fromCol,
      );
    }

    // --- CASTLING RIGHTS ---
    bool nextCastleWKS = state.canCastleWhiteKingSide;
    bool nextCastleWQS = state.canCastleWhiteQueenSide;
    bool nextCastleBKS = state.canCastleBlackKingSide;
    bool nextCastleBQS = state.canCastleBlackQueenSide;

    if (movingPiece.type == PieceType.king) {
      if (movingPiece.color == PieceColor.white) {
        nextCastleWKS = false;
        nextCastleWQS = false;
      } else {
        nextCastleBKS = false;
        nextCastleBQS = false;
      }
    } else if (movingPiece.type == PieceType.rook) {
      if (movingPiece.color == PieceColor.white) {
        if (move.fromCol == 0) nextCastleWQS = false;
        if (move.fromCol == 7) nextCastleWKS = false;
      } else {
        if (move.fromCol == 0) nextCastleBQS = false;
        if (move.fromCol == 7) nextCastleBKS = false;
      }
    }
    if (capturedPiece?.type == PieceType.rook) {
      if (move.toRow == 0 && move.toCol == 0) nextCastleBQS = false;
      if (move.toRow == 0 && move.toCol == 7) nextCastleBKS = false;
      if (move.toRow == 7 && move.toCol == 0) nextCastleWQS = false;
      if (move.toRow == 7 && move.toCol == 7) nextCastleWKS = false;
    }

    // --- PAWN PROMOTION ---
    if (movingPiece.type == PieceType.pawn) {
      if ((movingPiece.color == PieceColor.white && move.toRow == 0) ||
          (movingPiece.color == PieceColor.black && move.toRow == 7)) {
        if (state.gameMode == GameMode.pvp || state.turn == state.playerColor) {
          return state.copyWith(pendingPromotion: () => move);
        } else {
          // AI auto-promotes to Queen
          newSquares[move.toRow][move.toCol] = Piece(
            type: PieceType.queen,
            color: movingPiece.color,
          );
        }
      }
    }

    return _finalizeMoveLogic(
      state: state,
      move: move,
      newSquares: newSquares,
      newWhiteCaptured: newWhiteCaptured,
      newBlackCaptured: newBlackCaptured,
      nextEnPassantTarget: nextEnPassantTarget,
      nextCastleWKS: nextCastleWKS,
      nextCastleWQS: nextCastleWQS,
      nextCastleBKS: nextCastleBKS,
      nextCastleBQS: nextCastleBQS,
      evalBefore: evalBefore,
      movingPlayer: movingPlayer,
      isSacrifice: isSacrifice,
    );
  }

  GameState promotePiece(GameState state, PieceType type) {
    final move = state.pendingPromotion;
    if (move == null) return state;

    final evalBefore = _aiService.evaluateBoardStateWithRights(
      state.board,
      state.turn,  // FIX: Use actual moving player
      canCastleWKS: state.canCastleWhiteKingSide,
      canCastleWQS: state.canCastleWhiteQueenSide,
      canCastleBKS: state.canCastleBlackKingSide,
      canCastleBQS: state.canCastleBlackQueenSide,
      enPassantTarget: state.enPassantTarget,
    );
    final movingPlayer = state.turn;

    final newSquares = state.board.squares
        .map((row) => List<Piece?>.from(row))
        .toList();
    final movingPiece = newSquares[move.fromRow][move.fromCol];
    if (movingPiece == null) return state;

    final targetPiece = newSquares[move.toRow][move.toCol];
    final newWhiteCaptured = List<Piece>.from(state.whiteCaptured);
    final newBlackCaptured = List<Piece>.from(state.blackCaptured);

    if (targetPiece != null) {
      if (state.turn == PieceColor.white) {
        newWhiteCaptured.add(targetPiece);
      } else {
        newBlackCaptured.add(targetPiece);
      }
    }

    newSquares[move.toRow][move.toCol] = Piece(
      type: type,
      color: movingPiece.color,
    );
    newSquares[move.fromRow][move.fromCol] = null;

    return _finalizeMoveLogic(
      state: state,
      move: move,
      newSquares: newSquares,
      newWhiteCaptured: newWhiteCaptured,
      newBlackCaptured: newBlackCaptured,
      nextEnPassantTarget: null,
      nextCastleWKS: state.canCastleWhiteKingSide,
      nextCastleWQS: state.canCastleWhiteQueenSide,
      nextCastleBKS: state.canCastleBlackKingSide,
      nextCastleBQS: state.canCastleBlackQueenSide,
      evalBefore: evalBefore,
      movingPlayer: movingPlayer,
      isSacrifice: false,
    );
  }

  GameState _finalizeMoveLogic({
    required GameState state,
    required Move move,
    required List<List<Piece?>> newSquares,
    required List<Piece> newWhiteCaptured,
    required List<Piece> newBlackCaptured,
    required SquarePosition? nextEnPassantTarget,
    required bool nextCastleWKS,
    required bool nextCastleWQS,
    required bool nextCastleBKS,
    required bool nextCastleBQS,
    int? evalBefore,
    PieceColor? movingPlayer,
    bool isSacrifice = false,
  }) {
    final nextBoard = Board(newSquares);
    final nextTurn = state.turn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    // --- HALFMOVE CLOCK (50-MOVE RULE) (IMPROVED) ---
    final movingPiece = state.board.pieceAt(move.fromRow, move.fromCol);
    final captureTarget = state.board.pieceAt(move.toRow, move.toCol);
    final epCaptureExists = movingPiece?.type == PieceType.pawn &&
        state.enPassantTarget?.row == move.toRow &&
        state.enPassantTarget?.col == move.toCol;

    final nextHalfMoveClock = (movingPiece?.type == PieceType.pawn || 
                               captureTarget != null || 
                               epCaptureExists)
        ? 0
        : state.halfMoveClock + 1;

    var nextState = state.copyWith(
      board: nextBoard,
      turn: nextTurn,
      enPassantTarget: () => nextEnPassantTarget,
      canCastleWhiteKingSide: nextCastleWKS,
      canCastleWhiteQueenSide: nextCastleWQS,
      canCastleBlackKingSide: nextCastleBKS,
      canCastleBlackQueenSide: nextCastleBQS,
      halfMoveClock: nextHalfMoveClock,
    );

    // --- REPETITION DETECTION ---
    final positionKey = GameState.generatePositionKey(nextState);
    final nextPositionCounts = Map<String, int>.from(state.positionCounts);
    nextPositionCounts[positionKey] =
        (nextPositionCounts[positionKey] ?? 0) + 1;
    final nextMoveHistory = List<String>.from(state.moveHistory)
      ..add(positionKey);

    // --- AI CHAT LOGIC (IMPROVED) ---
    String? aiMessage;
    if (state.gameMode == GameMode.pva && nextTurn == state.playerColor) {
      final aiColor = state.playerColor == PieceColor.white
          ? PieceColor.black
          : PieceColor.white;
      final prevEval = _aiService.evaluateBoardState(state.board, aiColor);
      final currEval = _aiService.evaluateBoardState(nextBoard, aiColor);
      final diff = currEval - prevEval;

      // Higher thresholds to reduce spam
      if (diff > 250) {
        aiMessage = _trashTalkService.getComment(SarcasmType.userBlunder);
      } else if (diff < -200) {
        aiMessage = _trashTalkService.getComment(SarcasmType.userGoodMove);
      } else if (currEval > 700 && state.moveRecords.length > 20) {
        aiMessage = _trashTalkService.getComment(SarcasmType.aiWinning);
      } else if (currEval < -700 && state.moveRecords.length > 20) {
        aiMessage = _trashTalkService.getComment(SarcasmType.aiLosing);
      }
    }

    final status = _calculateStatus(
      nextBoard,
      nextTurn,
      nextEnPassantTarget,
      nextCastleWKS,
      nextCastleWQS,
      nextCastleBKS,
      nextCastleBQS,
      nextHalfMoveClock,
      nextPositionCounts[positionKey] ?? 0,
    );

    // --- MOVE RECORD (SIMPLIFIED DELTA) ---
    List<MoveRecord> nextMoveRecords = List<MoveRecord>.from(state.moveRecords);
    if (evalBefore != null && movingPlayer != null) {
      final evalAfter = _aiService.evaluateBoardStateWithRights(
        nextBoard,
        movingPlayer,
        canCastleWKS: nextCastleWKS,
        canCastleWQS: nextCastleWQS,
        canCastleBKS: nextCastleBKS,
        canCastleBQS: nextCastleBQS,
        enPassantTarget: nextEnPassantTarget,
      );
      // FIX: Simplified delta calculation
      final delta = evalAfter - evalBefore;
      nextMoveRecords.add(MoveRecord(
        move: move,
        player: movingPlayer,
        quality: MoveRecord.classify(delta, isSacrifice: isSacrifice),
        evalBefore: evalBefore,
        evalAfter: evalAfter,
        isSacrifice: isSacrifice,
      ));
    }

    return nextState.copyWith(
      selected: () => null,
      possibleMoves: const [],
      whiteCaptured: newWhiteCaptured,
      blackCaptured: newBlackCaptured,
      status: status,
      lastMove: move,
      pendingPromotion: () => null,
      aiMessage: aiMessage,
      positionCounts: nextPositionCounts,
      moveHistory: nextMoveHistory,
      moveRecords: nextMoveRecords,
    );
  }

  GameStatus _calculateStatus(
    Board board,
    PieceColor turn,
    SquarePosition? enPassantTarget,
    bool wks,
    bool wqs,
    bool bks,
    bool bqs,
    int halfMoveClock,
    int positionCount,
  ) {
    final isCheck = _validator.isKingInCheck(board, turn);
    bool hasMoves = false;

    // Optimized check for any legal move
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p != null && p.color == turn) {
          for (int tr = 0; tr < 8; tr++) {
            for (int tc = 0; tc < 8; tc++) {
              final canCastleK = turn == PieceColor.white ? wks : bks;
              final canCastleQ = turn == PieceColor.white ? wqs : bqs;
              if (_validator.isValidMove(
                board: board,
                move: Move(fromRow: r, fromCol: c, toRow: tr, toCol: tc),
                enPassantTarget: enPassantTarget,
                canCastleKingSide: canCastleK,
                canCastleQueenSide: canCastleQ,
              )) {
                hasMoves = true;
                break;
              }
            }
            if (hasMoves) break;
          }
        }
        if (hasMoves) break;
      }
    }

    if (!hasMoves) {
      return isCheck ? GameStatus.checkmate : GameStatus.draw;
    }

    // --- DRAW CONDITIONS ---
    if (positionCount >= 3) return GameStatus.draw;
    if (halfMoveClock >= 100) return GameStatus.draw;
    if (_isInsufficientMaterial(board)) return GameStatus.draw;

    return isCheck ? GameStatus.check : GameStatus.ongoing;
  }

  bool _isInsufficientMaterial(Board board) {
    final pieces = <Piece>[];
    final piecePositions = <int, (int, int)>{}; // index -> (row, col)

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p != null) {
          piecePositions[pieces.length] = (r, c);
          pieces.add(p);
        }
      }
    }

    // King vs King
    if (pieces.length == 2) return true;

    // King + Bishop vs King OR King + Knight vs King
    if (pieces.length == 3) {
      final other = pieces.firstWhere((p) => p.type != PieceType.king);
      if (other.type == PieceType.bishop || other.type == PieceType.knight) {
        return true;
      }
    }

    // King + Bishop vs King + Bishop (same color squares) - FIXED
    if (pieces.length == 4) {
      final whites = <int>[];
      final blacks = <int>[];
      
      for (int i = 0; i < pieces.length; i++) {
        if (pieces[i].color == PieceColor.white) {
          whites.add(i);
        } else {
          blacks.add(i);
        }
      }

      if (whites.length == 2 && blacks.length == 2) {
        final wBishopIdx = whites.firstWhere(
          (i) => pieces[i].type == PieceType.bishop,
          orElse: () => -1,
        );
        final bBishopIdx = blacks.firstWhere(
          (i) => pieces[i].type == PieceType.bishop,
          orElse: () => -1,
        );

        if (wBishopIdx != -1 && bBishopIdx != -1) {
          final wPos = piecePositions[wBishopIdx]!;
          final bPos = piecePositions[bBishopIdx]!;
          // Same color square = both bishops on light or both on dark
          final wSquareColor = (wPos.$1 + wPos.$2) % 2;
          final bSquareColor = (bPos.$1 + bPos.$2) % 2;
          return wSquareColor == bSquareColor;
        }
      }
    }

    return false;
  }

  bool _isSacrifice(Piece movingPiece, Piece? capturedPiece) {
    if (capturedPiece == null) return false;
    final moving = _pieceValue(movingPiece.type);
    final captured = _pieceValue(capturedPiece.type);
    return (moving - captured) >= 300;
  }

  int _pieceValue(PieceType type) {
    switch (type) {
      case PieceType.pawn:   return 100;
      case PieceType.knight: return 320;
      case PieceType.bishop: return 330;
      case PieceType.rook:   return 500;
      case PieceType.queen:  return 900;
      case PieceType.king:   return 20000;
    }
  }
}

