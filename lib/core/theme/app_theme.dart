import 'package:flutter/material.dart';

import 'app_dark_theme.dart';
import 'app_light_theme.dart';

class AppTheme {
  static ThemeData get light => AppLightTheme.theme;

  static ThemeData get dark => AppDarkTheme.theme;
}