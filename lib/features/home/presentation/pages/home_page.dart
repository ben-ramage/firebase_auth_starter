import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:firebase_auth_starter/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthCubit>().currentUser?.uid;

    if (uid != null) {
      context.read<ProfileCubit>().fetchUserProfile(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileLoaded) {
          final profileUser = state.profileUser;

          return Scaffold(
            appBar: AppBar(centerTitle: true, title: const Text('Home')),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: profileUser.profileImageUrl.isNotEmpty
                            ? NetworkImage(profileUser.profileImageUrl)
                            : null,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Welcome, ${profileUser.name}.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: Text('User not found.')));
      },
    );
  }
}
