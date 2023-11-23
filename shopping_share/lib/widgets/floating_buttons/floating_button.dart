import 'package:flutter/material.dart';

import 'package:shopping_share/theme.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed, // Customize the icon as needed
      backgroundColor: backgroundColor,
      child: const Icon(Icons.add), // Customize the FAB color
    );
  }
}
