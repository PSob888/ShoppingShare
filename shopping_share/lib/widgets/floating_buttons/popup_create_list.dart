import 'package:flutter/material.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/structs/shoppinglist.dart';
import 'package:shopping_share/theme.dart';

class CreateNewShoppingListPopup extends StatefulWidget {
  @override
  _CreateNewShoppingListPopupState createState() =>
      _CreateNewShoppingListPopupState();
}

class _CreateNewShoppingListPopupState
    extends State<CreateNewShoppingListPopup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController emailController = TextEditingController();
  AuthProvider _authProvider = AuthProvider();

  Future<void> createNewShoppingList(
      String userId, String shoppingListName) async {
    try {
      await FirebaseFirestore.instance.collection('lists').add({
        'user_id': userId,
        'name': shoppingListName,
        'created_at': DateTime.now(),
        'itemAmount': 0,
        'isDone': false,
        // Add other properties as needed
      });
    } catch (e) {
      print('Error creating new shopping list: $e');
    }
  }

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
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Nazwa',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // TODO: Add create new shopping list
              String? userId = _authProvider.user?.uid;
              if (userId != null) {
                String shoppingListName =
                    emailController.text; // get the value from the TextField
                await createNewShoppingList(userId, shoppingListName);
              }

              Navigator.pop(context); // Close the popup
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }
}