import 'package:flutter/material.dart';

class AppColor {
  // Legacy blue palette
  static const primary = Color(0xFF006BB3);
  static const blueLightest = Color(0xFFD7F4FE);
  static const blueLighter = Color(0xFFAAD9E9);
  static const blue = Color(0xFF62B8F6);
  static const blueDark = Color(0xFF3C99DD);
  static const blueDarker = Color(0xFF2C79C1);
  static const blueDarkest = Color(0xFF1B2541);
  static const white = Color(0xFFFFFFFF);

  static const pink = Color(0xFFFEE3D7);
  static const brownLight = Color(0xFFE9C8AA);
  static const orange = Color(0xFFF69762);
  static const orangeDark = Color(0xFFDD893C);
  static const orangeDarkest = Color(0xFFC1502C);

  static const blueBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [blue, blueDarker],
    stops: [0, 0.7],
  );

  // Dark theme — Retrouvé
  static const background = Color(0xFF0D1B2A);
  static const surface = Color(0xFF162436);
  static const surfaceLight = Color(0xFF1E3347);
  static const teal = Color(0xFF00C896);
  static const tealDark = Color(0xFF009E78);
  static const tealLight = Color(0xFF33D4A8);
  static const tealFaded = Color(0x2600C896);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8FA3B1);
  static const textMuted = Color(0xFF4A6580);
  static const appError = Color(0xFFFF5252);
  static const appSuccess = Color(0xFF4CAF50);
  static const appWarning = Color(0xFFFFB74D);
  static const dividerColor = Color(0xFF1E3347);

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealLight, tealDark],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1B2A), Color(0xFF091420)],
  );
}
