import 'package:firebase_auth_starter/features/auth/presentation/components/app_button.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/email_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/components/password_textfield.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:firebase_auth_starter/features/auth/presentation/cubits/auth_states.dart';
import 'package:firebase_auth_starter/features/profile/presentation/components/side_drawer.dart';
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

  Future<void> _changeEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authCubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    setState(() => _isSaving = true);

    try {
      final didChangeEmail = await authCubit.changeEmail(
        currentPassword: _currentPasswordController.text,
        newEmail: _newEmailController.text.trim(),
      );

      if (!didChangeEmail) {
        if (!mounted) return;

        final state = authCubit.state;
        final message = state is AuthSettingsError
            ? state.message
            : 'Unable to update email. Please try again.';

        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );

        return;
      }

      if (!mounted) return;

      _newEmailController.clear();
      _currentPasswordController.clear();

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Verification sent. Please verify your new email.'),
          backgroundColor: Colors.green,
        ),
      );

      await authCubit.logout();

      if (!mounted) return;
      router.pop();
    } catch (_) {
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
  Widget build(BuildContext context) {
    final currentEmail = context.read<AuthCubit>().currentUser?.email;

    if (currentEmail == null || currentEmail.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Update Email'),
          actions: const [SideDrawerButton()],
        ),
        endDrawer: const SideDrawer(),
        body: const Center(
          child: Text('Unable to load current email. Please log in again.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Email Address'),
        actions: const [SideDrawerButton()],
      ),
      endDrawer: const SideDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Updating your email signs you out. Verify your new '
                          'email address, then log back in.',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  initialValue: currentEmail,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ),
                    prefixIcon: Icon(Icons.mail, color: AppColors.primary),
                    labelText: 'Current email address',
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    floatingLabelStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.5),
                    ),
                    helperText: ' ',
                  ),
                ),
                const SizedBox(height: 2.5),
                EmailTextField(
                  emailController: _newEmailController,
                  label: 'New email address',
                ),
                const SizedBox(height: 2.5),
                PasswordTextfield(
                  passwordController: _currentPasswordController,
                  label: 'Current password',
                  isHidden: _isPasswordHidden,
                  toggleVisibility: () {
                    setState(() => _isPasswordHidden = !_isPasswordHidden);
                  },
                ),
                const SizedBox(height: 2.5),
                AppButton(
                  onTap: _isSaving ? null : _changeEmail,
                  text: 'Update email address',
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
    _newEmailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}
