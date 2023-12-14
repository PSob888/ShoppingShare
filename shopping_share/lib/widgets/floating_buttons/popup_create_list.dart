import 'package:flutter/material.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';
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
  TextEditingController nameController = TextEditingController(); // Changed variable name to nameController
  MyAuthProvider _authProvider = MyAuthProvider();

  Future<void> createNewShoppingList(
      String userId, String shoppingListName) async {
    try {
      await FirebaseFirestore.instance.collection('lists').add({
        'user_id': userId,
        'name': shoppingListName,
        'created_at': DateTime.now(),
        'itemAmount': 0,
        'isDone': false,
        'amountSpent': '0'
        // Add other properties as needed
      });
    } catch (e) {
      print('Error creating new shopping list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Container(
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
              controller: nameController,
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
                      nameController.text; // Use the updated variable name
                  await createNewShoppingList(userId, shoppingListName);
                }

                Navigator.pop(context); // Close the popup
              },
              child: const Text('Dodaj', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}