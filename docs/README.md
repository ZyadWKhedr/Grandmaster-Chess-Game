# Grandmaster Chess - Technical Documentation

Welcome to the comprehensive technical documentation for **Grandmaster Chess**, a modern, tournament-grade chess application built with Flutter, Riverpod, and Clean Architecture.

---

## 📚 Documentation Table of Contents

1. [**Chess AI Algorithm & Performance Guide**](CHESS_AI_ALGORITHM.md)
   - Deep mathematical and structural explanation of the AI engine:
     - Negamax with Alpha-Beta Pruning
     - Iterative Deepening with adaptive time budgeting
     - Transposition Tables with 64-bit Zobrist Hashing
     - Move Ordering (MVV-LVA, Killer Moves, History Heuristics)
     - Quiescence Search with Delta Pruning
     - Multi-faceted Board Evaluation (Material, PST, Mobility, King Safety)
     - Background Dart Isolates offloading (eliminating ANR, frame drops, and crashes)

2. [**App Architecture & SOLID Principles**](APP_ARCHITECTURE.md)
   - Clean Architecture layers (Core, Domain, Data, Presentation)
   - Concrete breakdown of each SOLID principle applied across the codebase
   - Riverpod State Management and Controller/Notifier patterns
   - Separation of UI into pure stateless sections and widgets (<200 lines per file)

3. [**Core Widgets & Design System**](CORE_WIDGETS.md)
   - Complete design system tokens: Tournament Green, Midnight Slate, Grandmaster Gold
   - Catalogue of reusable core widgets (`AppButton`, `AppCard`, `AppDialog`, `AppBadge`, `ResponsiveLayout`, `GlowContainer`)
   - Ergonomics, WCAG accessibility, and haptics guidelines

4. [**Refactoring & Optimization Summary**](REFACTORING_SUMMARY.md)
   - Before vs. After architectural comparison
   - Detailed analysis of memory leaks, GC churn, and UI thread blocking resolved
   - Checklist of completed objectives and statutory metrics (<200 lines, 100% Stateless UI)

