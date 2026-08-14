import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';

class AppScaffoldWithNavbar extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const AppScaffoldWithNavbar({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundPrimary,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: AppColors.secondary,
        selectedItemColor: AppColors.primary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _calculateSelectedIndex(state),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }

  int _calculateSelectedIndex(GoRouterState state) {
    final String location = state.uri.toString();

    if (location.startsWith('/home')) {
      return 0;
    }

    if (location.startsWith('/profile')) {
      return 1;
    }

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/profile');
        break;
    }
  }
}
