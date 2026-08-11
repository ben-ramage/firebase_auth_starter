import 'package:firebase_auth_starter/features/profile/presentation/pages/profile_page.dart';
import 'package:firebase_auth_starter/utils/app_theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Starter',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const ProfilePage(title: 'Firebase Auth Starter'),
    );
  }
}
