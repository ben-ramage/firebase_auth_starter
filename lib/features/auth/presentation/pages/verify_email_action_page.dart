import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailActionPage extends StatefulWidget {
  final String actionCode;

  const VerifyEmailActionPage({super.key, required this.actionCode});

  @override
  State<VerifyEmailActionPage> createState() => _VerifyEmailActionPageState();
}

class _VerifyEmailActionPageState extends State<VerifyEmailActionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().applyEmailVerificationCode(widget.actionCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
          return;
        }

        if (state is EmailVerificationAppliedSignedOut) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email verified. You can now log in."),
            ),
          );

          context.go('/');
          return;
        }

        if (state is EmailVerificationPending) {
          context.go('/verify-email');
          return;
        }

        if (state is Unauthenticated) {
          context.go('/');
          return;
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          context.go('/');
          return;
        }
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
