import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        actions: const [SideDrawerButton()],
      ),
      endDrawer: const SideDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Image.asset(
                  'images/security.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Keep your account secure and your details up to date. Manage your email address and password using the options below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const Icon(Icons.lock, size: 24),
              title: const Text(
                'Update password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Change your account password',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/settings/security/password'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: const Icon(Icons.email_outlined, size: 24),
              title: const Text(
                'Update email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Change your email address',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onTap: () => context.push('/settings/security/email'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ),
      ),
    );
  }
}
