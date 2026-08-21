import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verify your Email"),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 100, color: AppColors.alternateRed),
              const SizedBox(height: 20),
              const Text(
                "Please verify your email address.\n\n"
                "We've sent a verification link to your inbox. Once verified, you’ll be redirected automatically.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  final authCubit = context.read<AuthCubit>();

                  final sent = await authCubit.resendVerificationEmail();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        sent
                            ? "Verification email resent."
                            : "Unable to resend verification email.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text("Resend Verification Email"),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  await context.read<AuthCubit>().cancelEmailVerification();

                  if (!context.mounted) return;

                  context.go('/');
                },
                child: const Text(
                  'Return to login',
                  style: TextStyle(
                    color: AppColors.alternateRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
