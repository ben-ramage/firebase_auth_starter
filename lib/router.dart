import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth_starter/app_scaffold_with_navbar.dart';
import 'package:firebase_auth_starter/features/home/presentation/pages/home_page.dart';
import 'package:firebase_auth_starter/features/profile/presentation/pages/profile_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffoldWithNavbar(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(title: 'Home'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(title: 'Profile'),
          ),
        ],
      ),
    ],
  );
}
