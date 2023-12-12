import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_share/providers/AuthProvider.dart';

import 'package:shopping_share/theme.dart';

class AddFriendPopup extends StatefulWidget {
  @override
  _AddFriendPopupState createState() => _AddFriendPopupState();
}

class _AddFriendPopupState extends State<AddFriendPopup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController emailController = TextEditingController();
  AuthProvider _authProvider = AuthProvider();

  Future<void> addFriend(String senderID, String receiverID) async {
    try {
      await FirebaseFirestore.instance.collection('friend_reqs').add({
        'senderID': senderID,
        'receiverID': receiverID,
        'status': false,
      });
    } catch (e) {
      print('Error adding friend: $e');
    }
  }

  Future<void> addUserByEmail(String email, String myID) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((value) => value.docs.forEach((element) {
                if (myID != element.id) {
                  // TODO: add toast Nie mozesz zaprosic sam siebie, i toast nie znaleziono użytkownika
                  addFriend(myID, element.id);
                }
              }));
    } catch (e) {
      print('Error finding user: $e');
    }
  }

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
              'Dodaj znajomego',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Adres e-mail',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String? userId = _authProvider.user?.uid;
                if (userId != null) {
                  String friendEmail = emailController.text;
                  print(friendEmail);
                  addUserByEmail(friendEmail, userId);
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