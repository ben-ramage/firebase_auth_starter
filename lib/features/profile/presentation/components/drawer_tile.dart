import 'package:firebase_auth_starter/utils/app_colors.dart';
import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final FontWeight fontWeight;
  final Color splashColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool showChevron;

  const DrawerTile({
    super.key,
    required this.title,
    required this.fontWeight,
    required this.splashColor,
    this.icon,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 30, right: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          splashColor: splashColor,
          leading: Icon(icon, color: colorScheme.secondary),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: colorScheme.secondary,
            ),
          ),
          trailing: showChevron
              ? const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textPrimary,
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
