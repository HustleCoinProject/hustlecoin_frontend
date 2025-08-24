// lib/theme/responsive_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hustlecoin/app_colors.dart';
import 'package:hustlecoin/utils/responsive_utils.dart';

/// Responsive theme configuration
class ResponsiveTheme {
  static ThemeData buildTheme(BuildContext context) {
    ResponsiveUtils.init(context);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.angolaBlack,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            // Update text theme with responsive font sizes
            displayLarge: GoogleFonts.poppins(
              fontSize: 57.f,
              fontWeight: FontWeight.w400,
            ),
            displayMedium: GoogleFonts.poppins(
              fontSize: 45.f,
              fontWeight: FontWeight.w400,
            ),
            displaySmall: GoogleFonts.poppins(
              fontSize: 36.f,
              fontWeight: FontWeight.w400,
            ),
            headlineLarge: GoogleFonts.poppins(
              fontSize: 32.f,
              fontWeight: FontWeight.w400,
            ),
            headlineMedium: GoogleFonts.poppins(
              fontSize: 28.f,
              fontWeight: FontWeight.w400,
            ),
            headlineSmall: GoogleFonts.poppins(
              fontSize: 24.f,
              fontWeight: FontWeight.w400,
            ),
            titleLarge: GoogleFonts.poppins(
              fontSize: 22.f,
              fontWeight: FontWeight.w400,
            ),
            titleMedium: GoogleFonts.poppins(
              fontSize: 16.f,
              fontWeight: FontWeight.w500,
            ),
            titleSmall: GoogleFonts.poppins(
              fontSize: 14.f,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: GoogleFonts.poppins(
              fontSize: 16.f,
              fontWeight: FontWeight.w400,
            ),
            bodyMedium: GoogleFonts.poppins(
              fontSize: 14.f,
              fontWeight: FontWeight.w400,
            ),
            bodySmall: GoogleFonts.poppins(
              fontSize: 12.f,
              fontWeight: FontWeight.w400,
            ),
            labelLarge: GoogleFonts.poppins(
              fontSize: 14.f,
              fontWeight: FontWeight.w500,
            ),
            labelMedium: GoogleFonts.poppins(
              fontSize: 12.f,
              fontWeight: FontWeight.w500,
            ),
            labelSmall: GoogleFonts.poppins(
              fontSize: 11.f,
              fontWeight: FontWeight.w500,
            ),
          ),
      useMaterial3: true,
      // Update other theme properties to be responsive
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24.s, vertical: 12.s),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.s, vertical: 12.s),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
