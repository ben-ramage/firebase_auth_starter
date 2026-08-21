import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/auth_form_layout.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/password_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/responsive/constrained_scaffold.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatefulWidget {
  final String actionCode;

  const ResetPasswordPage({super.key, required this.actionCode});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _verifiedEmail;
  bool _isVerifying = true;
  bool isNewPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _verifyActionCode();
  }

  Future<void> _verifyActionCode() async {
    try {
      final email = await context.read<AuthCubit>().verifyPasswordResetCode(
        widget.actionCode,
      );

      if (!mounted) return;

      setState(() {
        _verifiedEmail = email;
        _isVerifying = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _verifiedEmail = null;
        _isVerifying = false;
      });
    }
  }

  void toggleNewPasswordVisibility() {
    setState(() => isNewPasswordHidden = !isNewPasswordHidden);
  }

  void toggleConfirmPasswordVisibility() {
    setState(() => isConfirmPasswordHidden = !isConfirmPasswordHidden);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              context.go('/');
            }
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          if (_verifiedEmail != null &&
              (state.message.contains('expired') ||
                  state.message.contains('Invalid') ||
                  state.message.contains('code'))) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.go('/');
              }
            });
          }
        }
      },
      child: ConstrainedScaffold(
        body: _isVerifying
            ? const Center()
            : _verifiedEmail == null
            ? _buildErrorView()
            : _buildResetForm(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Invalid Reset Link',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This password reset link is invalid or has expired. Please request a new one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          AppButton(onTap: () => context.go('/'), text: 'Back to Login'),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return AuthFormLayout(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Resetting password for:",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2.5),
              Text(
                _verifiedEmail ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              PasswordTextfield(
                passwordController: _passwordController,
                label: 'New Password',
                isHidden: isNewPasswordHidden,
                toggleVisibility: toggleNewPasswordVisibility,
              ),
              const SizedBox(height: 2.5),
              PasswordTextfield(
                passwordController: _confirmPasswordController,
                label: 'Confirm New Password',
                isHidden: isConfirmPasswordHidden,
                toggleVisibility: toggleConfirmPasswordVisibility,
                customValidator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }

                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),
              BlocBuilder<AuthCubit, AuthState>(
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
                            await _resetPassword();
                          },
                    text: isLoading ? "Updating..." : "Update Password",
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
              "Already a member? ",
              style: TextStyle(color: Colors.black),
            ),
            GestureDetector(
              onTap: () => context.go('/'),
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
    );
  }

  Future<void> _resetPassword() async {
    final newPassword = _passwordController.text.trim();

    await context.read<AuthCubit>().completePasswordReset(
      widget.actionCode,
      newPassword,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
