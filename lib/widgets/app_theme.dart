import 'package:flutter/material.dart';

/// المرجع الوحيد لكل قيم التصميم في التطبيق:
/// الألوان، الخطوط، المسافات، الانحناءات، والظلال.
/// أي Widget يحتاج قيمة تصميم يأخذها من هنا، ولا يكتبها مباشرة بنفسه.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------
  // الألوان الأساسية
  // ---------------------------------------------------------------------
  static const Color primaryPurple = Color(0xFF5E2A8C);
  static const Color darkPurple = Color(0xFF3D1B5C);
  static const Color lightPurple = Color(0xFFF3E9FF);

  static const Color secondaryTurquoise = Color(0xFF2FBFA6);
  static const Color goldAccent = Color(0xFFD4AF37);

  static const Color backgroundSoft = Color(0xFFFBF8FF);
  static const Color surfaceWhite = Colors.white;

  static const Color textPrimary = Color(0xFF2A1F38);
  static const Color textSecondary = Color(0xFF6B6377);
  static const Color textOnPrimary = Colors.white;

  // ألوان بطاقات الإحصائيات (عائلة لونية هادئة واحدة)
  static const Color statTotal = Color(0xFFB0479C);
  static const Color statPresent = Color(0xFF2FA86A);
  static const Color statAbsent = Color(0xFFE07A3F);
  static const Color statLate = Color(0xFF3E7CB1);

  // ألوان الأفاتار المحلية حسب الجنس
  static const Color avatarBoyBackground = Color(0xFFD8E8FF);
  static const Color avatarGirlBackground = Color(0xFFFFE0EC);

  // ---------------------------------------------------------------------
  // المسافات (Spacing Scale)
  // ---------------------------------------------------------------------
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 14;
  static const double spaceLg = 20;
  static const double spaceXl = 28;

  // ---------------------------------------------------------------------
  // الانحناءات (Radius Scale)
  // ---------------------------------------------------------------------
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 26;

  // ---------------------------------------------------------------------
  // الظلال الموحدة
  // ---------------------------------------------------------------------
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLifted => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ---------------------------------------------------------------------
  // الخطوط (Typography Scale)
  // ---------------------------------------------------------------------
  static const TextStyle headingLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle statNumber = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 12.5,
    color: textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle quickActionLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ---------------------------------------------------------------------
  // خلفية متدرّجة (تُستعمل خلف Dashboard)
  // ---------------------------------------------------------------------
  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lightPurple, backgroundSoft],
    ),
  );

  // ---------------------------------------------------------------------
  // ThemeData الكامل للتطبيق (Material 3)
  // ---------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        primary: primaryPurple,
        secondary: secondaryTurquoise,
        tertiary: goldAccent,
      ),
      scaffoldBackgroundColor: backgroundSoft,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: spaceSm,
          horizontal: spaceXs,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: spaceMd,
            horizontal: spaceLg,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}