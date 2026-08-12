import 'package:flutter/material.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';

class PasswordTextfield extends StatelessWidget {
  final TextEditingController passwordController;
  final String label;
  final bool isHidden;
  final VoidCallback toggleVisibility;
  final String? Function(String?)? customValidator;

  const PasswordTextfield({
    super.key,
    required this.passwordController,
    required this.label,
    required this.isHidden,
    required this.toggleVisibility,
    this.customValidator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: false,
      controller: passwordController,
      cursorColor: AppColors.primary,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.password],
      obscureText: isHidden,
      validator: (value) {
        final passwordRegex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
        );
        if (value == null || value.isEmpty) {
          return "Please enter a password";
        }
        if (!passwordRegex.hasMatch(value)) {
          return "Use 8+ chars with upper, lower, number, & symbol.";
        }
        if (customValidator != null) {
          return customValidator!(value);
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
        prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
        suffixIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashRadius: 0.1,
          onPressed: toggleVisibility,
          icon: isHidden
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2.5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2.5),
        ),
        helperText: ' ',
      ),
    );
  }
}
