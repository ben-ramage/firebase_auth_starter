import 'package:flutter/material.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';

class NameTextField extends StatelessWidget {
  final TextEditingController nameController;
  final String label;

  const NameTextField({
    super.key,
    required this.nameController,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      maxLength: 30,
      controller: nameController,
      keyboardType: TextInputType.name,
      cursorColor: AppColors.primary,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.name],
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter your name";
        }
        if (value.trim().length < 2) {
          return "Name must be at least 2 characters long";
        }
        final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
        if (!nameRegex.hasMatch(value)) {
          return "Only letters, spaces, hyphens, and apostrophes allowed";
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
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
          borderSide: BorderSide(width: 2.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(width: 2.0),
        ),
        helperText: ' ',
      ),
    );
  }
}
