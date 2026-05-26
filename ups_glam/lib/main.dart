import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: UPSGlamApp()));
}

class UPSGlamApp extends ConsumerWidget {
  const UPSGlamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _SplashScreen(),
      );
    }

    return MaterialApp(
      title: 'UPSGlam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.gold, width: 2.5),
              ),
              child: const Icon(Icons.language,
                  color: AppTheme.gold, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'UPSGlam',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppTheme.gold,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
