import 'package:firebase_auth_starter/features/auth/presentation/pages/forgot_password.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/login_page.dart';
import 'package:firebase_auth_starter/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

enum AuthView { login, register, forgotPassword }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  AuthView _authView = AuthView.login;

  void _switchToLogin() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _authView = AuthView.login;
    });
  }

  void _switchToRegister() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _authView = AuthView.register;
    });
  }

  void _switchToForgotPassword() {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _authView = AuthView.forgotPassword;
    });
  }

  Widget _buildCurrentView() {
    switch (_authView) {
      case AuthView.login:
        return LoginPage(
          key: const ValueKey(AuthView.login),
          onToggleRegister: _switchToRegister,
          onForgotPassword: _switchToForgotPassword,
        );
      case AuthView.register:
        return RegisterPage(
          key: const ValueKey(AuthView.register),
          onBackToLogin: _switchToLogin,
        );
      case AuthView.forgotPassword:
        return ForgotPasswordPage(
          key: const ValueKey(AuthView.forgotPassword),
          onBackToLogin: _switchToLogin,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentView(),
    );
  }
}
