import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';
import 'package:grandmaster_chess/features/home/presentation/pages/chess_home_page.dart';

void main() {
  testWidgets('ChessHomePage renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(const Size(360, 690));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => const MaterialApp(home: ChessHomePage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('GRANDMASTER CHESS'), findsOneWidget);
    expect(find.text('START GAME'), findsOneWidget);
    expect(find.text('QUICK MATCH PRESETS'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
