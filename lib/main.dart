import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nammabus/data_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Namma Bus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:
            const Color(0xFFF0F4F8), // Light Grey-Blue (Easy on eyes)
        primaryColor: const Color(0xFF005EA2), // Civic Blue

        // Public Sector Color Scheme
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF005EA2), // Trustworthy Blue
          onPrimary: Colors.white,
          secondary: Color(0xFFD32F2F), // Alert/Action Red
          surface: Colors.white,
          onSurface: Color(0xFF1B1B1B), // High contrast text
          tertiary: Color(0xFFFACE00), // Signal Yellow for highlights
        ),

        // TYPOGRAPHY: Public Sans (Clean, Government Standard)
        textTheme: TextTheme(
          displayLarge: GoogleFonts.publicSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B1B1B),
            letterSpacing: -0.5,
          ),
          titleMedium: GoogleFonts.publicSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF565C65), // Muted Label
            letterSpacing: 1.0,
            height: 1.5,
          ),
          headlineSmall: GoogleFonts.publicSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF005EA2),
          ),
          bodyMedium: GoogleFonts.publicSans(
            fontSize: 15,
            color: const Color(0xFF1B1B1B),
            height: 1.4,
          ),
          labelSmall: GoogleFonts.publicSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF565C65),
          ),
        ),

        // Accessible Input Fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF71767A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF71767A)), // Standard Grey
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: Color(0xFF005EA2), width: 2), // Focus Blue
          ),
          hintStyle: GoogleFonts.publicSans(color: const Color(0xFF565C65)),
        ),

        // Standard Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF005EA2),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: const DataScreen(),
    );
  }
}
