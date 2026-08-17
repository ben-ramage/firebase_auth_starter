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

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
