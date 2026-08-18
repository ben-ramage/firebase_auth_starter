import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailChangeActionPage extends StatefulWidget {
  final String actionCode;

  const VerifyEmailChangeActionPage({super.key, required this.actionCode});

  @override
  State<VerifyEmailChangeActionPage> createState() =>
      _VerifyEmailChangeActionPageState();
}

class _VerifyEmailChangeActionPageState
    extends State<VerifyEmailChangeActionPage> {
  String _message = "Updating email...";

  @override
  void initState() {
    super.initState();
    _applyEmailChangeCode();
  }

  Future<void> _applyEmailChangeCode() async {
    final success = await context.read<AuthCubit>().applyEmailChangeCode(
      widget.actionCode,
    );

    if (!mounted) return;

    setState(() {
      _message = success
          ? 'Email updated. Please log in with your new email.'
          : 'This email change link is invalid or has expired.';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
