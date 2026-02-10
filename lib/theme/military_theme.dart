import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MilitaryTheme {
  // ===== COLORS =====
  static const Color darkBackground = Color(0xFF0A0E14);
  static const Color cardBackground = Color(0xFF141A22);
  static const Color surfaceDark = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFF243044);

  static const Color militaryGreen = Color(0xFF2D5A27);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color brightGreen = Color(0xFF66BB6A);
  static const Color darkGreen = Color(0xFF1B3A18);

  static const Color goldAccent = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF176);
  static const Color goldDark = Color(0xFFE6B800);

  static const Color commandRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF42A5F5);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textMuted = Color(0xFF6B7280);

  // Priority Colors
  static const Color priorityCritical = Color(0xFFE53935);
  static const Color priorityHigh = Color(0xFFFF9800);
  static const Color priorityMedium = Color(0xFF42A5F5);
  static const Color priorityLow = Color(0xFF66BB6A);

  // Status Colors
  static const Color statusPending = Color(0xFF78909C);
  static const Color statusInProgress = Color(0xFFFFB74D);
  static const Color statusCompleted = Color(0xFF66BB6A);
  static const Color statusFailed = Color(0xFFE53935);

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
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 2,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 1.5,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: goldAccent,
            letterSpacing: 1.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 1,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: textMuted,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: accentGreen,
            letterSpacing: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: goldAccent,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: goldAccent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: goldAccent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surfaceLight, width: 0.5),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: militaryGreen,
        foregroundColor: goldAccent,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: militaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        selectedColor: militaryGreen,
        labelStyle: GoogleFonts.rajdhani(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        side: const BorderSide(color: surfaceLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceLight,
        thickness: 0.5,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: goldAccent, width: 1),
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====

  static Color getPriorityColor(int priorityIndex) {
    switch (priorityIndex) {
      case 0:
        return priorityLow;
      case 1:
        return priorityMedium;
      case 2:
        return priorityHigh;
      case 3:
        return priorityCritical;
      default:
        return priorityMedium;
    }
  }

  static Color getStatusColor(int statusIndex) {
    switch (statusIndex) {
      case 0:
        return statusPending;
      case 1:
        return statusInProgress;
      case 2:
        return statusCompleted;
      case 3:
        return statusFailed;
      default:
        return statusPending;
    }
  }

  static IconData getPriorityIcon(int priorityIndex) {
    switch (priorityIndex) {
      case 0:
        return Icons.arrow_downward;
      case 1:
        return Icons.remove;
      case 2:
        return Icons.arrow_upward;
      case 3:
        return Icons.warning_amber_rounded;
      default:
        return Icons.remove;
    }
  }

  static BoxDecoration get militaryCardDecoration {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceLight, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration get goldenAccentCard {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      boxShadow: [
        BoxShadow(
          color: goldAccent.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
