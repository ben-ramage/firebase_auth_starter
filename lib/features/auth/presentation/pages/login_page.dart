import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/auth_form_layout.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/email_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/password_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kRememberMeKey = 'rememberMe';
const String _kRememberedEmailKey = 'rememberedEmail';

class LoginPage extends StatefulWidget {
  final VoidCallback onToggleRegister;
  final VoidCallback onForgotPassword;

  const LoginPage({
    super.key,
    required this.onToggleRegister,
    required this.onForgotPassword,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHidden = true;
  bool rememberMe = false;

  final storage = const FlutterSecureStorage();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberMePreferences();
  }

  void togglePasswordVisibility() {
    setState(() => isHidden = !isHidden);
  }

  Future<void> _loadRememberMePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRememberMe = prefs.getBool(_kRememberMeKey) ?? false;

      if (!storedRememberMe) {
        if (!mounted) return;
        setState(() => rememberMe = false);
        return;
      }

      final storedEmail = await storage.read(key: _kRememberedEmailKey);

      if (!mounted) return;

      if (storedEmail != null && storedEmail.isNotEmpty) {
        setState(() {
          rememberMe = true;
          emailController.text = storedEmail;
        });
      } else {
        setState(() => rememberMe = false);
        await prefs.setBool(_kRememberMeKey, false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => rememberMe = false);
    }
  }

  Future<void> _saveRememberMePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRememberMeKey, rememberMe);

      if (rememberMe) {
        await storage.write(
          key: _kRememberedEmailKey,
          value: emailController.text.trim(),
        );
      } else {
        await storage.delete(key: _kRememberedEmailKey);
      }
    } catch (_) {
      // Login can continue if remember-me preferences fail to save.
    }
  }

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final authCubit = context.read<AuthCubit>();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }
    await _saveRememberMePreferences();
    await authCubit.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/create');
        } else if (state is EmailVerificationPending) {
          context.go('/verify-email');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthFormLayout(
        children: [
          EmailTextField(emailController: emailController, label: "Email"),
          const SizedBox(height: 2.5),
          PasswordTextfield(
            passwordController: passwordController,
            label: "Password",
            isHidden: isHidden,
            toggleVisibility: togglePasswordVisibility,
          ),
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (value) {
                  setState(() => rememberMe = value ?? false);
                },
                fillColor: WidgetStateProperty.all(AppColors.primary),
                checkColor: Colors.white,
              ),
              const Text(
                "Remember me",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onForgotPassword,
                child: const Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    "Forgot password?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return AppButton(
                onTap: state is AuthLoading ? null : login,
                text: "Continue",
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleRegister,
                child: const Text(
                  "Register",
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
