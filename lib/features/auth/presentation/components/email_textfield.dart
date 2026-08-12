import 'package:flutter/material.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:email_validator/email_validator.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController emailController;
  final String label;

  const EmailTextField({
    super.key,
    required this.emailController,
    required this.label,
  });

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_onEmailControllerChanged);
  }

  void _onEmailControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.emailController,
      cursorColor: AppColors.primary,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter an email";
        }
        if (!EmailValidator.validate(value.trim())) {
          return "Please enter a valid email address";
        }
        return null;
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(width: 2.0)),
        prefixIcon: const Icon(Icons.mail, color: AppColors.primary),
        suffixIcon: widget.emailController.text.isEmpty
            ? null
            : IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                splashRadius: 0.1,
                icon: Icon(Icons.clear),
                onPressed: () {
                  widget.emailController.clear();
                  setState(() {});
                },
              ),
        labelText: widget.label,
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

  @override
  void dispose() {
    widget.emailController.removeListener(_onEmailControllerChanged);
    super.dispose();
  }
}
