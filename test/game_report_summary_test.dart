import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/move_record.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/narrow_game_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/services/game_coordinator.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/widgets/game_report_dialog.dart';

void main() {
  group('MoveRecord accuracy & classification calculations', () {
    test('Calculates Win% and move accuracy correctly using Lichess model', () {
      // Equal position (0 cp)
      expect(MoveRecord.winP(0), closeTo(50.0, 0.1));

      // 1 pawn advantage (+100 cp) -> ~59.1%
      expect(MoveRecord.winP(100), closeTo(59.1, 0.5));

      // Move with 0 loss gives ~100% accuracy
      expect(MoveRecord.moveAccuracy(100, 100), closeTo(100.0, 0.1));

      // Move with small drop (5% drop) gives ~80% accuracy
      final loss5Accuracy = MoveRecord.moveAccuracy(100, 78);
      expect(loss5Accuracy, greaterThan(75.0));
      expect(loss5Accuracy, lessThan(95.0));

      // Blunder gives low accuracy
      final blunderAccuracy = MoveRecord.moveAccuracy(200, -300);
      expect(blunderAccuracy, lessThan(30.0));
    });

    test('Both White and Black compute accurate delta without sign flipping bugs', () {
      final whiteRecord = MoveRecord(
        move: const Move(fromRow: 6, fromCol: 4, toRow: 4, toCol: 4),
        player: PieceColor.white,
        quality: MoveQuality.good,
        evalBefore: 0,
        evalAfter: 20,
      );
      expect(whiteRecord.delta, equals(20));

      final blackRecord = MoveRecord(
        move: const Move(fromRow: 1, fromCol: 4, toRow: 3, toCol: 4),
        player: PieceColor.black,
        quality: MoveQuality.good,
        evalBefore: 0,
        evalAfter: 30, // Black gained 30 cp from black's perspective
      );
      expect(blackRecord.delta, equals(30));
    });

    test('Computes overall game accuracy and performance tier', () {
      final records = [
        MoveRecord(
          move: const Move(fromRow: 6, fromCol: 4, toRow: 4, toCol: 4),
          player: PieceColor.white,
          quality: MoveQuality.good,
          evalBefore: 0,
          evalAfter: 5,
        ),
        MoveRecord(
          move: const Move(fromRow: 7, fromCol: 6, toRow: 5, toCol: 5),
          player: PieceColor.white,
          quality: MoveQuality.good,
          evalBefore: 5,
          evalAfter: 10,
        ),
      ];

      final acc = MoveRecord.accuracy(records);
      expect(acc, greaterThan(95.0));
      expect(MoveRecord.performanceTier(acc), equals('Grandmaster'));
    });
  });

  group('Game Coordinator & Manual Summary Trigger Tests', () {
    testWidgets('GameOver does NOT automatically show GameReportDialog', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      final coordinator = container.read(gameCoordinatorProvider);

      final state = GameState.initial(mode: GameMode.pva).copyWith(
        status: GameStatus.checkmate,
        moveRecords: [
          MoveRecord(
            move: const Move(fromRow: 6, fromCol: 4, toRow: 4, toCol: 4),
            player: PieceColor.white,
            quality: MoveQuality.good,
            evalBefore: 0,
            evalAfter: 10,
          ),
        ],
      );

      late BuildContext capturedContext;
      late WidgetRef capturedRef;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => MaterialApp(
              home: Consumer(
                builder: (ctx, ref, _) {
                  capturedContext = ctx;
                  capturedRef = ref;
                  return Scaffold(body: NarrowGameLayout(state: state));
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger status change
      coordinator.handleStatusChange(capturedContext, capturedRef, state, GameStatus.checkmate);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // GameReportDialog should NOT be showing automatically!
      expect(find.byType(GameReportDialog), findsNothing);

      // User sees GameOver dialog or Game Summary button
      expect(find.text('view_report'), findsWidgets);
    });

    testWidgets('Clicking View Report button opens GameReportDialog', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      final state = GameState.initial(mode: GameMode.pva).copyWith(
        status: GameStatus.checkmate,
        moveRecords: [
          MoveRecord(
            move: const Move(fromRow: 6, fromCol: 4, toRow: 4, toCol: 4),
            player: PieceColor.white,
            quality: MoveQuality.good,
            evalBefore: 0,
            evalAfter: 15,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            builder: (context, child) => MaterialApp(
              home: Scaffold(body: NarrowGameLayout(state: state)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Button is visible because game is in terminal status
      final reportBtn = find.text('view_report');
      expect(reportBtn, findsOneWidget);

      // User taps button
      await tester.tap(reportBtn);
      await tester.pumpAndSettle();

      // Now the summary dialog appears!
      expect(find.byType(GameReportDialog), findsOneWidget);
      expect(find.text('report_card'), findsOneWidget);
    });
  });
}
