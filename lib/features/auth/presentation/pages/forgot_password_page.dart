import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/auth_form_layout.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/email_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordPage({super.key, required this.onBackToLogin});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Future<void> _onResetPassword() async {
    final email = _emailController.text.trim();

    await context.read<AuthCubit>().requestPasswordReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetEmailSent) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text(
                  "Password reset email sent! Please check your inbox.",
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              widget.onBackToLogin();
            }
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: AuthFormLayout(
        children: [
          const Text(
            'Forgot your password?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                EmailTextField(
                  emailController: _emailController,
                  label: "What's your email address?",
                ),
                const SizedBox(height: 20),
                BlocBuilder(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return AppButton(
                      onTap: isLoading
                          ? null
                          : () async {
                              final isValid =
                                  _formKey.currentState?.validate() ?? false;

                              if (!isValid) return;

                              FocusManager.instance.primaryFocus?.unfocus();
                              await _onResetPassword();
                            },
                      text: isLoading ? "Sending..." : "Reset Password",
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: AppColors.primary),
              ),
              GestureDetector(
                onTap: widget.onBackToLogin,
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: AppColors.alternateRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.alternateRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
