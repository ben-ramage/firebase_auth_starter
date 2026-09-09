import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('About'),
        actions: const [SideDrawerButton()],
      ),
      endDrawer: const SideDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'images/infographic.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Firebase Auth Starter is a reusable Flutter project that provides "
                    "the essential account features needed to get an app started.\n\n"
                    "It includes registration, login, email verification, account settings, "
                    "and editable user profiles. Built as a learning project, it demonstrates "
                    "how Flutter, Cubit, and Firebase work together to create a clean, "
                    "organised foundation for a larger application.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
