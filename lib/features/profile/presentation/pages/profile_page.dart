import 'package:firebase_auth_starter/features/auth/domain/entities/app_user.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authCubit = context.read<AuthCubit>();
  late AppUser? currentUser = authCubit.currentUser;

  bool get _isOwnProfile =>
      currentUser != null && widget.uid == currentUser!.uid;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = _isOwnProfile;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileLoaded) {
            final profileUser = state.profileUser;

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(profileUser.email),
                actions: isOwnProfile ? const [SideDrawerButton()] : null,
              ),
              endDrawer: isOwnProfile ? const SideDrawer() : null,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: profileUser.profileImageUrl.isNotEmpty
                            ? NetworkImage(profileUser.profileImageUrl)
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        profileUser.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profileUser.bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (isOwnProfile)
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            onTap: () => context.push('/profile/edit'),
                            text: "Edit Profile",
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Scaffold(body: Center(child: Text("User not found.")));
        },
      ),
    );
  }
}
