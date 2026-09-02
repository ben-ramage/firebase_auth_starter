import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  final String uid;

  const AccountSettingsPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Security'),
        actions: const [SideDrawerButton()],
      ),
    );
  }
}
