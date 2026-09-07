import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _newEmailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> changeEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authCubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);

    try {} catch (_) {
      final didChangeEmail = await authCubit.changeEmail(
        currentPassword: _currentPasswordController.text,
        newEmail: _newEmailController.text.trim(),
      );
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to update email. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}
