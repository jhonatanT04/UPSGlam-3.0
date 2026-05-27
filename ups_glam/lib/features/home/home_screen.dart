import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../feed/feed_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import '../upload/upload_screen.dart';

final homeTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _screens = [
    FeedScreen(),
    SearchScreen(),
    UploadScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    return Scaffold(
      body: IndexedStack(index: tab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.inputBorder, width: 0.5)),
        ),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) =>
              ref.read(homeTabProvider.notifier).state = i,
          destinations: [
            NavigationDestination(
              icon: Icon(tab == 0 ? Icons.home : Icons.home_outlined),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(
                tab == 1 ? Icons.search : Icons.search_outlined,
                color: tab == 1 ? AppTheme.navy : null,
              ),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: tab == 2 ? AppTheme.upsGradient : null,
                  border: tab == 2
                      ? null
                      : Border.all(color: AppTheme.textPrimary, width: 1.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.add,
                  color: tab == 2 ? AppTheme.gold : AppTheme.textPrimary,
                  size: 20,
                ),
              ),
              label: 'Subir',
            ),
            NavigationDestination(
              icon: Icon(tab == 3 ? Icons.person : Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
