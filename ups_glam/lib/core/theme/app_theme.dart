import 'package:flutter/material.dart';

/// Paleta UPSGlam
/// Azul UPS institucional como primario, blanco roto para superficies,
/// acento coral para acciones principales.
class AppTheme {
  AppTheme._();

  // ── Colores ────────────────────────────────
  static const Color primary = Color(0xFF0D47A1);    // Azul UPS
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color accent = Color(0xFFFF5252);     // Coral / like
  static const Color surface = Color(0xFFF8F9FC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color inputBorder = Color(0xFFE0E4EF);
  static const Color error = Color(0xFFEF4444);

  // ── Gradiente de fondo auth ────────────────
  static const LinearGradient authBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF42A5F5)],
    stops: [0.0, 0.5, 1.0],
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        fontFamily: 'Poppins', // añadir en pubspec.yaml
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            elevation: 0,
          ),
        ),
      );
}
