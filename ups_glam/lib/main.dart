import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ups_glam/features/auth/login_screen.dart';
import 'core/theme/app_theme.dart';


void main() {
  runApp(
    const ProviderScope(
      child: UPSGlamApp(),
    ),
  );
}

class UPSGlamApp extends StatelessWidget {
  const UPSGlamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPSGlam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
  
}

