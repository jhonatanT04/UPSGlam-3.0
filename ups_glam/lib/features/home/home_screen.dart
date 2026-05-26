import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../feed/feed_screen.dart';
import '../profile/profile_screen.dart';
import '../upload/upload_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _screens = [
    FeedScreen(),
    UploadScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.inputBorder, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            NavigationDestination(
              icon: Icon(_tab == 0 ? Icons.home : Icons.home_outlined),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: _tab == 1 ? AppTheme.upsGradient : null,
                  border: _tab == 1
                      ? null
                      : Border.all(color: AppTheme.textPrimary, width: 1.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add,
                  color: _tab == 1 ? AppTheme.gold : AppTheme.textPrimary,
                  size: 20,
                ),
              ),
              label: 'Subir',
            ),
            NavigationDestination(
              icon: Icon(_tab == 2 ? Icons.person : Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
