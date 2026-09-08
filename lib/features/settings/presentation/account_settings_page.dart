import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSettingsPage extends StatelessWidget {
  final String uid;

  const AccountSettingsPage({super.key, required this.uid});

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
              context.go('/profile/$uid');
            }
          },
        ),
        actions: const [SideDrawerButton()],
      ),
      endDrawer: const SideDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Update password'),
            subtitle: const Text('Change your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/security/password'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Update email'),
            subtitle: const Text('Change your email address'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/security/email'),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
