import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Paleta UPS ──────────────────────────────────────
  static const Color navy     = Color(0xFF0C2C6E); // Azul marino UPS
  static const Color navyLight= Color(0xFF1A4499); // Azul medio
  static const Color gold     = Color(0xFFF5A500); // Dorado UPS
  static const Color goldLight= Color(0xFFFFBF2E); // Dorado claro
  static const Color like     = Color(0xFFED4956); // Rojo like (estilo Instagram)
  static const Color background = Color(0xFFFAFAFA);
  static const Color white    = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color inputBorder   = Color(0xFFDBDBDB);
  static const Color error    = Color(0xFFED4956);

  // ── Aliases para compatibilidad ───────────────────
  static const Color primary      = navy;
  static const Color accent       = gold;
  static const Color surface      = white;

  // ── Gradiente UPS ────────────────────────────────
  static const LinearGradient upsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, navyLight, Color(0xFF2060C0)],
  );

  // Gradiente dorado para highlights
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          brightness: Brightness.light,
          primary: navy,
          secondary: gold,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          shadowColor: inputBorder,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: white,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: navy, size: 26);
            }
            return const IconThemeData(color: textSecondary, size: 24);
          }),
          height: 60,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: navy,
            foregroundColor: white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: navy),
        ),
        dividerTheme: const DividerThemeData(
          color: inputBorder,
          thickness: 0.5,
          space: 0,
        ),
      );
}
