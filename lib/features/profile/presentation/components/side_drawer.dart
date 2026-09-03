import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/drawer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentUserId = authCubit.currentUser?.uid;

    if (currentUserId == null) {
      return const Drawer(child: SizedBox.shrink());
    }

    void navigateTo(String path) {
      Navigator.of(context).pop();
      context.go(path);
    }

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: DrawerTile(
                title: 'Account',
                icon: Icons.person,
                fontWeight: FontWeight.bold,
                onTap: () =>
                    navigateTo('/profile/$currentUserId/account_settings'),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.inversePrimary),
            const Spacer(),
            DrawerTile(
              title: 'Logout',
              icon: Icons.logout,
              fontWeight: FontWeight.bold,
              onTap: () async {
                await authCubit.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SideDrawerButton extends StatelessWidget {
  const SideDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        );
      },
    );
  }
}
