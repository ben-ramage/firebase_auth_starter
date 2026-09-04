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
        String appBarTitle = 'Home';

        if (state is ProfileLoaded) {
          appBarTitle = 'Welcome, ${state.profileUser.name}';
        }
        return Scaffold(
          appBar: AppBar(centerTitle: true, title: Text(appBarTitle)),
          body: Center(
            child: Column(mainAxisAlignment: .center, children: [
            ],
          ),
          ),
        );
      },
    );
  }
}
