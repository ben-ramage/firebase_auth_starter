import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/drawer_tile.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
      child: Column(
        children: [
          const SizedBox(height: 20),
          SvgPicture.asset('images/fire_starter.svg', width: 180),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          DrawerTile(
            title: 'Account',
            icon: Icons.person,
            fontWeight: FontWeight.bold,
            splashColor: AppColors.accountSplash.withValues(alpha: 0.50),
            onTap: () {},
            // onTap: () => navigateTo('/profile/$currentUserId/account_settings'),
          ),
          const Spacer(),
          DrawerTile(
            title: 'Logout',
            icon: Icons.logout,
            fontWeight: FontWeight.bold,
            splashColor: AppColors.logoutSplash.withValues(alpha: 0.50),
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 150));
              await authCubit.logout();
            },
          ),
        ],
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
