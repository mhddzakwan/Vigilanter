import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'vigilanter_bottom_nav.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.biruVigilanter,
      body: SafeArea(
        child: navigationShell,
      ),
      bottomNavigationBar: SafeArea(
        child: VigilanterBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onItemTapped(context, index),
        ),
      ),
    );
  }
}
