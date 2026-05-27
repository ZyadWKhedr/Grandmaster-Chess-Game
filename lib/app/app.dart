import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/theme/app_theme.dart';

import 'package:grandmaster_chess/features/splash/presentation/pages/splash_screen.dart';
import 'package:grandmaster_chess/features/settings/presentation/providers/theme_provider.dart';


class ChessApp extends ConsumerWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Grandmaster Chess',
          debugShowCheckedModeBanner: false,

          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates:
              context.localizationDelegates,

          themeMode: themeMode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,

          home: const SplashScreen(),
        );
      },
    );
  }
}