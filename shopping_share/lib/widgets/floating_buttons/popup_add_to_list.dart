import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddToListPopup extends StatefulWidget {
  final String listUid;

  AddToListPopup({required this.listUid});

  @override
  _AddToListPopupState createState() => _AddToListPopupState();
}

class _AddToListPopupState extends State<AddToListPopup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dodaj nowy produkt',
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
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                hintText: 'Ilość',
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Krótki opis',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await addProductToFirestore();
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }

Future<void> addProductToFirestore() async {
  String name = nameController.text;
  String quantity = quantityController.text;
  String description = descriptionController.text;

  CollectionReference itemsCollection = FirebaseFirestore.instance
      .collection('lists')
      .doc(widget.listUid)
      .collection('items');

  // Get the current itemAmount from Firestore
  int currentItemAmount = 0; // You may want to set a default value
  await FirebaseFirestore.instance
      .collection('lists')
      .doc(widget.listUid)
      .get()
      .then((doc) {
    if (doc.exists) {
      currentItemAmount = doc['itemAmount'] ?? 0;
    }
  });

  // Increment the itemAmount
  int newItemAmount = currentItemAmount + 1;

  // Update the itemAmount in Firestore
  await FirebaseFirestore.instance
      .collection('lists')
      .doc(widget.listUid)
      .update({'itemAmount': newItemAmount});

  // Add the new item to the collection
  await itemsCollection.add({
    'listId': widget.listUid,
    'name': name,
    'quantity': quantity,
    'description': description,
    'bought': false,
  });

  // Clear the text controllers
  nameController.clear();
  quantityController.clear();
  descriptionController.clear();
}
}
