import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFFEC5B13);
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF221610);
  static const Color warmCream = Color(0xFFF5F2E9);
  static const Color darkAction = Color(0xFF221610);
  
  // Custom Slate Colors (Material-like)
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

  // Text Colors
  static const Color textMain = slate900;
  static const Color textSecondary = slate600;
  static const Color textStone800 = Color(0xFF292524);
  static const Color textStone600 = Color(0xFF57534E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: warmCream,
      ),
      scaffoldBackgroundColor: backgroundLight,
      
      textTheme: GoogleFonts.lexendTextTheme().copyWith(
        displayLarge: GoogleFonts.lexend(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textMain,
          height: 1.15,
        ),
        headlineLarge: GoogleFonts.lexend(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
        headlineMedium: GoogleFonts.lexend(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.publicSans(
          fontSize: 18,
          color: textMain,
        ),
        bodyMedium: GoogleFonts.publicSans(
          fontSize: 16,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.publicSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAction,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.publicSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 4,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.publicSans(
          color: Colors.grey[400],
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE7E5E4)), 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE7E5E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.publicSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Aliases & design tokens (mess owner + shared UI) ---
  static const Color primary = primaryColor;
  static const Color background = backgroundLight;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = slate900;
  static const Color textMuted = slate500;
  static const Color divider = Color(0xFFE7E5E4);

  static const Color popular = Color(0xFFFFB74D);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color onSurface = slate900;
  static const Color onSurfaceMuted = slate500;
  static const Color surfaceVariant = Color(0xFFF9FAFB);
  
  static Color get primaryContainer => primaryColor.withValues(alpha: 0.12);
  static const Color primaryLight = Color(0xFFFFEBE3);
  static const Color primaryMuted = Color(0xFFFDBA74);
  static const Color primaryDark = Color(0xFFC2410C);
  
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  
  static const Color navActive = primaryColor;
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color navy = Color(0xFF0F172A);
  static const Color cardBorder = Color(0xFFE7E5E4);
  static const Color borderColor = Color(0xFFE7E5E4);
  static const Color progressBackground = Color(0xFFF4F4F5);
  static const Color muted = slate500;
  static const Color secondary = slate600;
  static const Color accent = primaryColor;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEC5B13), Color(0xFFE85D19)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
