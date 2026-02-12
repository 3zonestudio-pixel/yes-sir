import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CuteTheme {
  // ===== COLORS - Fresh Green palette matching app logo =====
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F1F1A);
  static const Color cardBackground = Color(0xFF1A332B);
  static const Color surfaceDark = Color(0xFF213D33);
  static const Color surfaceLight = Color(0xFF2A4A3E);

  // Primary & Accent
  static const Color primaryPink = Color(0xFF5CC9A7);   // Light mint
  static const Color accentLavender = Color(0xFF2D8C6F); // Rich green
  static const Color brightMint = Color(0xFF7FDBCA);     // Bright mint
  static const Color deepPink = Color(0xFF337060);        // Logo green
  static const Color softPink = Color(0xFF8BBFA0);        // Soft sage

  static const Color peachAccent = Color(0xFF6ECF9F);
  static const Color peachLight = Color(0xFFA8E6CF);
  static const Color lavenderDark = Color(0xFF2D8C6F);

  static const Color coralRed = Color(0xFFE85D5D);
  static const Color warningPeach = Color(0xFFFFA07A);
  static const Color infoCyan = Color(0xFF7DD3FC);
  static const Color softPurple = Color(0xFF8BBFA0);

  static const Color textPrimary = Color(0xFFF0FFF8);
  static const Color textSecondary = Color(0xFFBFDDD0);
  static const Color textMuted = Color(0xFF7FAA98);

  // Priority Colors - Cute variants
  static const Color priorityCritical = Color(0xFFFF6B6B);
  static const Color priorityHigh = Color(0xFFFFA07A);
  static const Color priorityMedium = Color(0xFFB19CD9);
  static const Color priorityLow = Color(0xFF77DD77);

  // Status Colors
  static const Color statusPending = Color(0xFFCBBFE0);
  static const Color statusInProgress = Color(0xFFC3A6FF);
  static const Color statusCompleted = Color(0xFF7FDBCA);
  static const Color statusFailed = Color(0xFFFF8FAB);

  // ===== DARK THEME =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryPink,
        secondary: accentLavender,
        tertiary: brightMint,
        surface: cardBackground,
        error: coralRed,
        onPrimary: Color(0xFF1A1625),
        onSecondary: Color(0xFF1A1625),
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: 0.5),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primaryPink, letterSpacing: 0.5),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryPink, letterSpacing: 0.3),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryPink,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: primaryPink.withOpacity(0.2),
        labelStyle: GoogleFonts.nunito(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: surfaceLight, thickness: 0.5),
      dialogTheme: DialogTheme(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
      ),
    );
  }

  // ===== HELPER METHODS =====

  static Color getPriorityColor(int priorityIndex) {
    switch (priorityIndex) {
      case 0: return priorityLow;
      case 1: return priorityMedium;
      case 2: return priorityHigh;
      case 3: return priorityCritical;
      default: return priorityMedium;
    }
  }

  static Color getStatusColor(int statusIndex) {
    switch (statusIndex) {
      case 0: return statusPending;
      case 1: return statusInProgress;
      case 2: return statusCompleted;
      case 3: return statusFailed;
      default: return statusPending;
    }
  }

  static IconData getPriorityIcon(int priorityIndex) {
    switch (priorityIndex) {
      case 0: return Icons.favorite_border_rounded;
      case 1: return Icons.favorite_rounded;
      case 2: return Icons.local_fire_department_rounded;
      case 3: return Icons.whatshot_rounded;
      default: return Icons.favorite_rounded;
    }
  }

  static BoxDecoration get cuteCardDecoration {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: primaryPink.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    );
  }

  static BoxDecoration get lavenderAccentCard {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accentLavender.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(color: accentLavender.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
      ],
    );
  }

  static BoxDecoration get softPinkCard {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryPink.withOpacity(0.12), primaryPink.withOpacity(0.04)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }

  // ===== LIGHT THEME =====
  static const Color lightBackground = Color(0xFFF0FAF5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFE3F5ED);
  static const Color lightSurfaceAlt = Color(0xFFD0EEE0);
  static const Color lightTextPrimary = Color(0xFF1B3D30);
  static const Color lightTextSecondary = Color(0xFF4A7A65);
  static const Color lightTextMuted = Color(0xFF8BBFA0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: deepPink,
        secondary: lavenderDark,
        tertiary: brightMint,
        surface: lightCard,
        error: coralRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextPrimary, letterSpacing: 0.5),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextPrimary),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: deepPink, letterSpacing: 0.5),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lightTextPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: lightTextPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: lightTextSecondary),
          bodySmall: TextStyle(fontSize: 12, color: lightTextMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: deepPink, letterSpacing: 0.3),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: lightTextPrimary),
        iconTheme: const IconThemeData(color: lightTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightCard,
        selectedItemColor: deepPink,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 2,
        shadowColor: const Color(0x15337060),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: deepPink,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deepPink, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: const Color(0x30337060),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurface,
        selectedColor: deepPink.withOpacity(0.15),
        labelStyle: GoogleFonts.nunito(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: lightSurfaceAlt, thickness: 0.5),
      dialogTheme: DialogTheme(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
      ),
    );
  }
}
