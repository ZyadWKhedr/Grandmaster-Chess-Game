# Chess AI Engine & Performance Optimization

## 1. Overview & Architecture

The Grandmaster Chess AI engine is a high-performance evaluation and search system designed specifically for mobile and cross-platform devices. It blends game-theoretic search algorithms with positional heuristics and runs entirely off the main thread in background Dart Isolates to ensure a locked 60/120 FPS UI.

```mermaid
flowchart TD
    UI[Flutter UI - Main Isolate] -->|findBestMoveAsync| Isolate[Background Dart Isolate]
    subgraph Isolate ["Background Dart Isolate (Zero UI Thread Impact)"]
        ID[Iterative Deepening Controller] -->|Depth 1..N + Time Budget| Nega[Negamax Search + Alpha-Beta]
        Nega <--> TT[Transposition Table (64K Slots + Zobrist Hash)]
        Nega --> MO[Move Ordering: PV, MVV-LVA, Killer, History]
        Nega -->|Horizon Reached| QS[Quiescence Search + Delta Pruning]
        QS --> Eval[Board Evaluator: Material + PST + Mobility + King Safety]
    end
    Isolate -->|Best Move Result| UI
```

---

## 2. Core Search Algorithms

### 2.1 Negamax with Alpha-Beta Pruning
Rather than maintaining separate Minimax branches for White (maximizing) and Black (minimizing), the engine uses the mathematically equivalent **Negamax formulation**:

$$\text{score}(p) = \max_{m \in \text{Moves}} \left( -\text{score}(p') \right)$$

#### Alpha-Beta Pruning
At any node, the search maintains a search window $[\alpha, \beta]$:
- $\alpha$: The minimum score that the maximizing player is assured of.
- $\beta$: The maximum score that the minimizing player can allow the maximizing player.

When a branch produces a score $s \ge \beta$, the opponent can avoid this position entirely. A **beta cutoff** occurs, pruning all subsequent sibling branches and cutting exponential branching factors by up to 80%.

### 2.2 Iterative Deepening & Time Budgeting
Rather than jumping immediately into a deep search (e.g., depth 4 or 5), the engine iteratively evaluates depth 1, then depth 2, then depth 3, etc.:
1. **Move Ordering Seed**: Moves evaluated at depth $d-1$ populate the Transposition Table and Killer tables, so depth $d$ searches the most promising moves first.
2. **Deterministic Time Guards**: Old versions would freeze on high-end phones and crash on low-end phones when depth 4 took unexpected time. The engine now bounds each search with a strict stopwatch budget:
   - **Beginner**: Depth 1 (Max 300ms)
   - **Intermediate**: Depth 2 (Max 700ms)
   - **Master**: Depth 3 (Max 1400ms)
   - **Grandmaster**: Depth 4 (Max 2200ms)

If time expires between depth iterations, the engine safely halts and returns the verified best move from the completed depth.

---

## 3. Heuristics & Search Optimizations

### 3.1 Transposition Table (TT) & 64-bit Zobrist Hashing
During a game of chess, different move sequences often transpose to the identical board configuration (e.g. `1. e4 e5 2. Nf3 Nc6` vs `1. Nf3 Nc6 2. e4 e5`).

1. **Zobrist Keying**: Each square, piece type, piece color, castling right, and en-passant column is pre-assigned a pseudo-random 64-bit integer. Computing the hash of a new board requires simple XOR operations:
   $$K_{\text{new}} = K_{\text{old}} \oplus Z[\text{piece}, \text{from}] \oplus Z[\text{piece}, \text{to}]$$
2. **Compact Cache Design**:
   - Previous implementation allocated **1,048,576 nullable entries**, consuming over 16MB of contiguous RAM and clearing it in a 1-million iteration loop. On low-end Android devices with 192MB heap limits, this triggered Out-Of-Memory (OOM) crashes.
   - The optimized table uses **65,536 entries** (`0x10000` with `0xFFFF` bitmask) and C-level memory filling via `_table.fillRange(0, 65536, null)`. Clearing takes **< 0.1ms** and uses negligible RAM.

### 3.2 Move Ordering
Search efficiency depends heavily on exploring the best moves first:
1. **Transposition Table Move**: If the position was visited in an earlier depth, test its recorded best move first.
2. **MVV-LVA (Most Valuable Victim - Least Valuable Attacker)**: Captures are scored by $\text{VictimValue} - \text{AttackerValue}$. For example, Pawn takes Queen is searched before Queen takes Pawn.
3. **Killer Move Heuristic**: Moves that caused a beta-cutoff at the same search depth in sibling branches are tested next.
4. **History Heuristic**: Maintains a frequency table of quiet moves that caused cutoffs throughout the search tree.

### 3.3 Quiescence Search & Delta Pruning
The "Horizon Effect" occurs when standard search halts at depth 0 right in the middle of a piece exchange (e.g., thinking it captured a Queen, failing to see the Queen is immediately recaptured).

1. **Selective Capture Search**: At depth 0, Quiescence Search evaluates only captures and promotions until the tactical position is "quiet".
2. **Search Depth Cap**: Capped strictly at 4 plies to avoid infinite capture cascades.
3. **Delta Pruning**: If the static evaluation ($\text{standPat}$) plus the maximum possible material gain (Queen = 950) is still strictly less than $\alpha$, the capture cannot possibly raise $\alpha$, allowing the branch to be pruned immediately:
   $$\text{standPat} + 950 < \alpha \implies \text{Prune Branch}$$

---

## 4. Positional Board Evaluation

The board score is evaluated from the perspective of the side to move using 4 balanced components:

$$\text{Evaluation} = \text{Material} + \text{PST} + \text{Mobility} + \text{KingSafety}$$

### 4.1 Material Weights
- Pawn: 100
- Knight: 320
- Bishop: 330
- Rook: 500
- Queen: 900
- King: 20,000

### 4.2 Piece-Square Tables (PST)
Positional tables encourage pieces to occupy optimal squares:
- Pawns are encouraged to control the center (d4, e4, d5, e5) and advance towards promotion ranks.
- Knights are heavily rewarded for central outposts and penalized on rim squares ("knights on the rim are dim").
- Rooks are rewarded on open central files (c, d, e).
- Kings are rewarded for castled safety in the opening/middlegame and active central migration in the endgame.

### 4.3 Mobility & King Safety
- **Mobility**: Measures pseudo-legal move options for knights, bishops, rooks, and queens to reward active, piece-coordinated play.
- **King Safety**: Penalizes open files in front of a castled king and rewards intact pawn shields.

---

## 5. Background Isolate Architecture (Zero Freezes)

### Why the App Previously Froze & Crashed
1. **Main UI Thread Execution**: In Flutter, running an intensive calculation on the root isolate blocks the engine's event loop. Frames cannot render, gestures are ignored, and Android displays the "Application Not Responding" (ANR) crash dialog.
2. **Garbage Collection (GC) Pressure**: Allocating millions of short-lived `Board`, `List`, and `String` objects inside Negamax caused Android's GC to pause execution repeatedly.

### The Solution: `compute` and Isolate Decoupling
The AI engine runs through `ChessAIService.findBestMoveAsync`:

```dart
Future<Move?> findBestMoveAsync(GameState gameState) async {
  final params = _AiComputeParams(
    board: gameState.board,
    turn: gameState.turn,
    whiteKingSide: gameState.canCastleWhiteKingSide,
    whiteQueenSide: gameState.canCastleWhiteQueenSide,
    blackKingSide: gameState.canCastleBlackKingSide,
    blackQueenSide: gameState.canCastleBlackQueenSide,
    enPassant: gameState.enPassantTarget,
    difficulty: gameState.aiDifficulty,
  );

  return compute(_isolateSearch, params);
}
```

- **Independent Memory Heap**: The background isolate runs in its own memory space and thread pool.
- **Buttery 60/120 FPS**: The UI thread remains completely free to animate loaders, handle clicks, and process user interaction without hitching.

