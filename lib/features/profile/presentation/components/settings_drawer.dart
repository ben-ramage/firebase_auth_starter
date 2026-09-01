import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  final String title;
  final IconData? icon;
  final FontWeight fontWeight;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const SettingsDrawer({
    super.key,
    required this.title,
    this.icon,
    required this.fontWeight,
    this.iconColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: fontWeight, color: textColor),
      ),
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
    );
  }
}
