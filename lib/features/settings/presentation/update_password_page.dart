import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/password_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentHidden = true;
  bool _isNewHidden = true;
  bool _isConfirmHidden = true;
  bool _isSaving = false;

  Future<void> _changePassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirmation do not match.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authCubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);

    try {
      final didChangePassword = await authCubit.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!didChangePassword) {
        if (!mounted) return;

        final state = authCubit.state;
        final message = state is AuthSettingsError
            ? state.message
            : 'Unable to update password. Please try again.';

        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );

        return;
      }

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      messenger.showSnackBar(
        SnackBar(
          content: Text('Password updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Unable to update password. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Password'),
        actions: const [SideDrawerButton()],
      ),
      endDrawer: const SideDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Update your password by verifying your old password & creating a new password.',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                PasswordTextfield(
                  passwordController: _currentPasswordController,
                  label: 'Current password',
                  isHidden: _isCurrentHidden,
                  toggleVisibility: () {
                    setState(() => _isCurrentHidden = !_isCurrentHidden);
                  },
                ),
                const SizedBox(height: 2.5),
                PasswordTextfield(
                  passwordController: _newPasswordController,
                  label: 'New password',
                  isHidden: _isNewHidden,
                  toggleVisibility: () {
                    setState(() => _isNewHidden = !_isNewHidden);
                  },
                  customValidator: (value) {
                    if (value == _currentPasswordController.text) {
                      return 'New password must be different.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 2.5),
                PasswordTextfield(
                  passwordController: _confirmPasswordController,
                  label: 'Confirm new password',
                  isHidden: _isConfirmHidden,
                  toggleVisibility: () {
                    setState(() => _isConfirmHidden = !_isConfirmHidden);
                  },
                  customValidator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 2.5),
                AppButton(
                  onTap: _isSaving ? null : _changePassword,
                  text: 'Update password',
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
