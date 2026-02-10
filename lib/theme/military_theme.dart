import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MilitaryTheme {
  // ===== COLORS - Warm, comfortable military palette =====
  static const Color darkBackground = Color(0xFF111318);
  static const Color cardBackground = Color(0xFF1B1E25);
  static const Color surfaceDark = Color(0xFF22262F);
  static const Color surfaceLight = Color(0xFF2D3340);

  static const Color militaryGreen = Color(0xFF2D6A4F);
  static const Color accentGreen = Color(0xFF52B788);
  static const Color brightGreen = Color(0xFF74C69D);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color softGreen = Color(0xFF95D5B2);

  static const Color goldAccent = Color(0xFFFFD166);
  static const Color goldLight = Color(0xFFFFE08A);
  static const Color goldDark = Color(0xFFE6B800);

  static const Color commandRed = Color(0xFFEF476F);
  static const Color warningOrange = Color(0xFFFF9F1C);
  static const Color infoBlue = Color(0xFF4CC9F0);
  static const Color softPurple = Color(0xFFB5838D);

  static const Color textPrimary = Color(0xFFEDF2F4);
  static const Color textSecondary = Color(0xFFB0B8C1);
  static const Color textMuted = Color(0xFF6C757D);

  // Priority Colors
  static const Color priorityCritical = Color(0xFFEF476F);
  static const Color priorityHigh = Color(0xFFFF9F1C);
  static const Color priorityMedium = Color(0xFF4CC9F0);
  static const Color priorityLow = Color(0xFF74C69D);

  // Status Colors
  static const Color statusPending = Color(0xFF8D99AE);
  static const Color statusInProgress = Color(0xFFFFB703);
  static const Color statusCompleted = Color(0xFF52B788);
  static const Color statusFailed = Color(0xFFEF476F);

  // ===== THEME DATA =====
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: goldAccent,
        surface: cardBackground,
        error: commandRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: 1),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
          headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: goldAccent, letterSpacing: 1),
          headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accentGreen, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: goldAccent,
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: accentGreen.withOpacity(0.2),
        labelStyle: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: surfaceLight, thickness: 0.5),
      dialogTheme: DialogTheme(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      case 0: return Icons.keyboard_arrow_down_rounded;
      case 1: return Icons.remove_rounded;
      case 2: return Icons.keyboard_arrow_up_rounded;
      case 3: return Icons.priority_high_rounded;
      default: return Icons.remove_rounded;
    }
  }

  static BoxDecoration get militaryCardDecoration {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    );
  }

  static BoxDecoration get goldenAccentCard {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: goldAccent.withOpacity(0.2), width: 1),
      boxShadow: [
        BoxShadow(color: goldAccent.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4)),
      ],
    );
  }

  static BoxDecoration get softGreenCard {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [accentGreen.withOpacity(0.12), accentGreen.withOpacity(0.04)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
}
