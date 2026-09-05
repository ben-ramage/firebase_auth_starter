import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final FontWeight fontWeight;
  final Color splashColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const DrawerTile({
    super.key,
    required this.title,
    required this.fontWeight,
    required this.splashColor,
    this.icon,
    this.onTap,
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
          title: Text(
            title,
            style: TextStyle(
              fontWeight: fontWeight,
              color: colorScheme.secondary,
            ),
          ),
          leading: Icon(icon, color: colorScheme.secondary),
          onTap: onTap,
        ),
      ),
    );
  }
}
