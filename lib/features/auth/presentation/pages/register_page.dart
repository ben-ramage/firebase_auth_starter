import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/auth_form_layout.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/email_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/name_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/password_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const RegisterPage({super.key, required this.onBackToLogin});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _pageController = PageController();
  int _currentPage = 0;

  bool _isHidden = true;
  void togglePasswordVisibility() => setState(() => _isHidden = !_isHidden);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> nextPage() async {
    FocusScope.of(context).unfocus();

    if (_currentPage == 0) {
      final name = _nameController.text.trim();
      if (!(_nameFormKey.currentState?.validate() ?? false)) return;

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your name to continue.")),
        );
        return;
      }
    } else if (_currentPage == 1) {
      final password = _passwordController.text;
      if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a password to continue.")),
        );
        return;
      }
      await register();
      return;
    }

    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      if (!mounted) return;

      setState(() {
        _currentPage++;
      });
    }
  }

  void previousPage() {
    if (_currentPage <= 0) return;

    FocusManager.instance.primaryFocus?.unfocus();

    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentPage--;
    });
  }

  Future<void> register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }
    await context.read<AuthCubit>().register(
      name,
      email,
      password,
      confirmPassword,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.alternateRed,
                duration: const Duration(seconds: 3),
              ),
            );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNameEmailPage(isLoading),
                  _buildPasswordsPage(isLoading),
                ],
              ),
              if (_currentPage > 0)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: IconButton(
                      onPressed: isLoading ? null : previousPage,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
              if (isLoading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withAlpha(76),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameEmailPage(bool isLoading) {
    return Form(
      key: _nameFormKey,
      child: _buildFormContent(
        isLoading: isLoading,
        children: [
          NameTextField(
            nameController: _nameController,
            label: "What's your name?",
          ),
          const SizedBox(height: 2.5),
          EmailTextField(
            emailController: _emailController,
            label: "What's your email address?",
          ),
          const SizedBox(height: 7.5),
          AppButton(
            onTap: isLoading ? null : nextPage,
            text: isLoading ? "Loading..." : "Continue",
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordsPage(bool isLoading) {
    return Form(
      key: _passwordFormKey,
      child: _buildFormContent(
        isLoading: isLoading,
        children: [
          PasswordTextfield(
            passwordController: _passwordController,
            label: "Create a password",
            isHidden: _isHidden,
            toggleVisibility: togglePasswordVisibility,
          ),
          const SizedBox(height: 2.5),
          PasswordTextfield(
            passwordController: _confirmPasswordController,
            label: "Confirm your password",
            isHidden: _isHidden,
            toggleVisibility: togglePasswordVisibility,
          ),
          const SizedBox(height: 7.5),
          AppButton(
            onTap: isLoading ? null : nextPage,
            text: isLoading ? "Loading..." : "Register",
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent({
    required List<Widget> children,
    required bool isLoading,
  }) {
    return AuthFormLayout(
      children: [
        ...children,
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account? ",
              style: TextStyle(color: Colors.black),
            ),
            GestureDetector(
              onTap: isLoading ? null : widget.onBackToLogin,
              child: const Text(
                "Log in",
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
}
