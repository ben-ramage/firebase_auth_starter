import 'package:firebase_auth_starter/utils/app_theme.dart';
import 'package:firebase_auth_starter/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Starter',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
