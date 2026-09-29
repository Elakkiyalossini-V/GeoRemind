import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgDeep = Color(0xFF0A0917);
  static const bgApp = Color(0xFF100E22);
  static const surface = Color(0xFF17142E);
  static const surface2 = Color(0xFF1E1A3D);
  static const purple1 = Color(0xFF4835C4);
  static const purple2 = Color(0xFF6D5AE8);
  static const emerald = Color(0xFF12D992);
  static const emeraldDim = Color(0xFF0B8F63);
  static const textHi = Color(0xFFF3F1FB);
  static const textMid = Color(0xFFABA6C9);
  static const textLow = Color(0xFF6E698F);
  static const glassFill = Color(0x0DFFFFFF); // rgba(255,255,255,0.055)
  static const glassFill2 = Color(0x17FFFFFF); // rgba(255,255,255,0.09)
  static const glassBorder = Color(0x17FFFFFF);
  static const danger = Color(0xFFF26A6A);
  static const amber = Color(0xFFF2B84B);

  static const mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple1, purple2, emerald],
    stops: [0.0, 0.48, 1.0],
  );

  static const emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldDim, emerald],
  );
}

class AppRadius {
  static const lg = 22.0;
  static const md = 16.0;
  static const sm = 10.0;
}

class AppText {
  static TextStyle display({double size = 19, FontWeight weight = FontWeight.w600, Color color = AppColors.textHi}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body({double size = 14, FontWeight weight = FontWeight.w400, Color color = AppColors.textHi}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle mono({double size = 12, FontWeight weight = FontWeight.w500, Color color = AppColors.textHi}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgApp,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.purple2,
      secondary: AppColors.emerald,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: TextTheme(bodyMedium: AppText.body()),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

/// Background used behind every screen: two soft radial glows over deep navy,
/// matching the prototype's `body { background: radial-gradient(...), var(--bg-deep) }`.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.85),
          radius: 1.0,
          colors: [Color(0x596D5AE8), Colors.transparent],
        ),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.bgDeep),
        child: child,
      ),
    );
  }
}
