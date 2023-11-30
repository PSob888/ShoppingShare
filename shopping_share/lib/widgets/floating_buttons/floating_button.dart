import 'package:flutter/material.dart';

import 'package:shopping_share/theme.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed, // Customize the icon as needed
      backgroundColor: floatingButtonColor,
      child: const Icon(Icons.add, color: Color(0xFF446792), size: 40), // Customize the FAB color
    );
  }
}
