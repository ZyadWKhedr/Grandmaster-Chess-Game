import 'package:grandmaster_chess/features/gameplay/domain/entities/board.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/square_position.dart';
import '../core/search_result.dart';
import '../core/search_state.dart';
import '../core/transposition_table.dart';
import '../core/zobrist.dart';
import '../evaluation/board_evaluator.dart';
import '../move_generation/move_generator.dart';
import 'heuristics/history_heuristic.dart';
import 'heuristics/killer_moves.dart';
import 'heuristics/move_ordering.dart';
import 'heuristics/repetition_detector.dart';
import 'quiescence.dart';

class Negamax {
  final MoveGenerator _moveGenerator = MoveGenerator();
  final BoardEvaluator _evaluator = BoardEvaluator();
  final KillerMoves _killerMoves = KillerMoves();
  final HistoryHeuristic _history = HistoryHeuristic();
  final RepetitionDetector _repetition = RepetitionDetector();
  final TranspositionTable _tt = TranspositionTable();
  final Zobrist _zobrist = Zobrist();
  late final MoveOrdering _moveOrdering;
  late final Quiescence _quiescence;

  Negamax() {
    _moveOrdering = MoveOrdering(_killerMoves, _history);
    _quiescence = Quiescence(_evaluator, _moveGenerator);
  }

  SearchResult search({required SearchState state, required int depth}) {
    _tt.clear();

    int bestScore = -999999;
    Move? bestMove;
    const int alpha = -999999;
    const int beta = 999999;

    final moves = _moveGenerator.generateMoves(state);
    _moveOrdering.sort(moves, state.board, depth);

    for (final move in moves) {
      final nextState = applyMove(state, move);
      final score = -_negamax(
        state: nextState,
        depth: depth - 1,
        alpha: -beta,
        beta: -alpha,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return SearchResult(bestMove: bestMove, evaluation: bestScore);
  }

  int _negamax({
    required SearchState state,
    required int depth,
    required int alpha,
    required int beta,
  }) {
    final key = _zobrist.computeKey(state);

    // Transposition table lookup
    final ttEntry = _tt.get(key);
    if (ttEntry != null && ttEntry.depth >= depth) {
      switch (ttEntry.type) {
        case TTEntryType.exact:
          return ttEntry.score;
        case TTEntryType.lowerBound:
          if (ttEntry.score > alpha) alpha = ttEntry.score;
          break;
        case TTEntryType.upperBound:
          if (ttEntry.score < beta) beta = ttEntry.score;
          break;
      }
      if (alpha >= beta) return ttEntry.score;
    }

    // Repetition check
    final posKey = _getBoardKey(state);
    final repetitionPenalty = _repetition.penalty(posKey);
    if (repetitionPenalty >= 100000) return 0; // forced draw

    // Leaf node: quiescence search
    if (depth <= 0) {
      final score = _quiescence.search(state: state, alpha: alpha, beta: beta);
      return score - repetitionPenalty;
    }

    final moves = _moveGenerator.generateMoves(state);
    _moveOrdering.sort(moves, state.board, depth);

    // No legal moves: checkmate or stalemate
    if (moves.isEmpty) {
      return -999000 + (100 - depth); // prefer later checkmates
    }

    int best = -999999;
    Move? bestMove;
    // ignore: unused_local_variable
    var alphaOrig = alpha;
    var entryType = TTEntryType.upperBound;

    _repetition.add(posKey);

    for (final move in moves) {
      final nextState = applyMove(state, move);
      final score = -_negamax(
        state: nextState,
        depth: depth - 1,
        alpha: -beta,
        beta: -alpha,
      );

      if (score > best) {
        best = score;
        bestMove = move;
      }

      if (score > alpha) {
        alpha = score;
        entryType = TTEntryType.exact;
      }

      if (alpha >= beta) {
        _killerMoves.add(depth, move);
        _history.add(move, depth);
        entryType = TTEntryType.lowerBound;
        break;
      }
    }

    // Store result in transposition table
    _tt.put(
      key: key,
      depth: depth,
      score: best,
      type: entryType,
      bestMove: bestMove,
    );

    return best;
  }

  /// Applies a move to a SearchState, correctly handling:
  /// - Standard moves
  /// - Castling (king + rook teleport)
  /// - En Passant (captured pawn removal)
  /// - Pawn Promotion (auto-promote to Queen for AI)
  /// - Updated castling rights
  /// - Updated en passant target
  SearchState applyMove(SearchState state, Move move) {
    final squares = state.board.squares
        .map((r) => List<Piece?>.from(r))
        .toList();

    final movingPiece = squares[move.fromRow][move.fromCol];
    if (movingPiece == null) return state; // safety guard

    // --- Move the piece ---
    squares[move.toRow][move.toCol] = movingPiece;
    squares[move.fromRow][move.fromCol] = null;

    // --- Special: Castling ---
    if (movingPiece.type == PieceType.king) {
      final colDiff = move.toCol - move.fromCol;
      if (colDiff == 2) {
        // King-side: move rook from col 7 to col 5
        squares[move.fromRow][5] = squares[move.fromRow][7];
        squares[move.fromRow][7] = null;
      } else if (colDiff == -2) {
        // Queen-side: move rook from col 0 to col 3
        squares[move.fromRow][3] = squares[move.fromRow][0];
        squares[move.fromRow][0] = null;
      }
    }

    // --- Special: En Passant capture ---
    SquarePosition? newEnPassant;
    if (movingPiece.type == PieceType.pawn) {
      final rowDiff = move.toRow - move.fromRow;
      final colDiff = move.toCol - move.fromCol;

      // Detect en passant capture: diagonal move to empty square
      if (colDiff != 0 && squares[move.toRow][move.toCol] == movingPiece) {
        // The captured pawn is on the same row as we started, in the target column
        if (state.enPassant != null &&
            state.enPassant!.row == move.toRow &&
            state.enPassant!.col == move.toCol) {
          // Remove the captured pawn (it sits on move.fromRow, move.toCol)
          squares[move.fromRow][move.toCol] = null;
        }
      }

      // Set new en passant target for double pawn push
      if (rowDiff.abs() == 2) {
        final epRow = move.fromRow + (rowDiff ~/ 2);
        newEnPassant = SquarePosition(epRow, move.fromCol);
      }
    }

    // --- Special: Pawn Promotion (auto-promote to Queen) ---
    if (movingPiece.type == PieceType.pawn) {
      if (move.toRow == 0 || move.toRow == 7) {
        squares[move.toRow][move.toCol] =
            Piece(type: PieceType.queen, color: movingPiece.color);
      }
    }

    // --- Update castling rights ---
    var wks = state.whiteKingSide;
    var wqs = state.whiteQueenSide;
    var bks = state.blackKingSide;
    var bqs = state.blackQueenSide;

    if (movingPiece.type == PieceType.king) {
      if (movingPiece.color == PieceColor.white) {
        wks = false;
        wqs = false;
      } else {
        bks = false;
        bqs = false;
      }
    }
    if (movingPiece.type == PieceType.rook) {
      if (move.fromRow == 7 && move.fromCol == 7) wks = false;
      if (move.fromRow == 7 && move.fromCol == 0) wqs = false;
      if (move.fromRow == 0 && move.fromCol == 7) bks = false;
      if (move.fromRow == 0 && move.fromCol == 0) bqs = false;
    }
    // If a rook is captured on its starting square, also remove rights
    if (move.toRow == 7 && move.toCol == 7) wks = false;
    if (move.toRow == 7 && move.toCol == 0) wqs = false;
    if (move.toRow == 0 && move.toCol == 7) bks = false;
    if (move.toRow == 0 && move.toCol == 0) bqs = false;

    final nextTurn =
        state.turn == PieceColor.white ? PieceColor.black : PieceColor.white;

    return SearchState(
      board: Board(squares),
      turn: nextTurn,
      whiteKingSide: wks,
      whiteQueenSide: wqs,
      blackKingSide: bks,
      blackQueenSide: bqs,
      enPassant: newEnPassant,
    );
  }

  String _getBoardKey(SearchState state) {
    final sb = StringBuffer();
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = state.board.pieceAt(r, c);
        if (p == null) {
          sb.write('.');
        } else {
          final letter = p.type.name[0];
          sb.write(p.color == PieceColor.white
              ? letter.toUpperCase()
              : letter.toLowerCase());
        }
      }
    }
    sb.write(state.turn == PieceColor.white ? 'w' : 'b');
    return sb.toString();
  }
}