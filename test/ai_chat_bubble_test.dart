import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/ai/presentation/widgets/ai_chat_bubble.dart';
import 'package:grandmaster_chess/features/gameplay/domain/entities/piece.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/pages/layouts/narrow_game_layout.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/chess_game_notifier.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/providers/game_state.dart';
import 'package:grandmaster_chess/features/gameplay/presentation/sections/game_board_section.dart';

void main() {
  testWidgets('AiChatBubble renders text and dismisses on tap', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    final notifier = container.read(chessGameProvider.notifier);

    notifier.initGame(GameMode.pva);
    notifier.state = notifier.state.copyWith(aiMessage: 'Checkmate soon!');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(body: AiChatBubble()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Checkmate soon!'), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Tap to dismiss
    await tester.tap(find.byType(AiChatBubble));
    await tester.pumpAndSettle();

    expect(container.read(chessGameProvider).aiMessage, isNull);
    expect(find.text('Checkmate soon!'), findsNothing);
  });

  testWidgets('GameBoardSection does not contain AiChatBubble', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final state = GameState.initial(mode: GameMode.pva).copyWith(
      aiMessage: 'Covering nothing!',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: GameBoardSection(state: state),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AiChatBubble is NOT within GameBoardSection
    expect(find.descendant(
      of: find.byType(GameBoardSection),
      matching: find.byType(AiChatBubble),
    ), findsNothing);
  });

  testWidgets('NarrowGameLayout positions AiChatBubble above GameBoardSection', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    final notifier = container.read(chessGameProvider.notifier);
    notifier.initGame(GameMode.pva, playerColor: PieceColor.white);
    notifier.state = notifier.state.copyWith(aiMessage: 'Clear view of the board');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NarrowGameLayout(state: notifier.state),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bubbleFinder = find.byType(AiChatBubble);
    final boardFinder = find.byType(GameBoardSection);

    expect(bubbleFinder, findsOneWidget);
    expect(boardFinder, findsOneWidget);

    final bubbleBottom = tester.getBottomLeft(bubbleFinder).dy;
    final boardTop = tester.getTopLeft(boardFinder).dy;

    // Bubble must be strictly ABOVE the board section!
    expect(bubbleBottom, lessThanOrEqualTo(boardTop));
  });
}
