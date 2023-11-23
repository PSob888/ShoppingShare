import 'package:flutter/material.dart';

import 'package:shopping_share/theme.dart';

class CreateNewShoppingListPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Stwórz nową listę',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Nazwa',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Add product to the list
              Navigator.pop(context); // Close the popup
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}
