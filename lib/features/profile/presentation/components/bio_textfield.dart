import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';

class BioTextfield extends StatelessWidget {
  final TextEditingController bioController;
  final String label;

  const BioTextfield({
    super.key,
    required this.bioController,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: bioController,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 150,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value != null && value.length > 150) {
          return "Bio cannot exceed 150 characters";
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
        helperText: ' ',
      ),
    );
  }
}
