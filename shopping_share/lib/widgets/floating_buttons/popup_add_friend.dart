import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';

import 'package:shopping_share/theme.dart';

class AddFriendPopup extends StatefulWidget {
  @override
  _AddFriendPopupState createState() => _AddFriendPopupState();
}

class _AddFriendPopupState extends State<AddFriendPopup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController emailController = TextEditingController();
  MyAuthProvider _authProvider = MyAuthProvider();

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
      // Fetch the user ID associated with the provided email
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String friendId = userQuery.docs.first.id;

        // Check if there is a friend request with the same sender and receiver IDs
        QuerySnapshot existingRequestSameIds = await FirebaseFirestore.instance
            .collection('friend_reqs')
            .where('senderID', isEqualTo: myID)
            .where('receiverID', isEqualTo: friendId)
            .get();

        // Check if there is a friend request with opposite sender and receiver IDs
        QuerySnapshot existingRequestOppositeIds = await FirebaseFirestore
            .instance
            .collection('friend_reqs')
            .where('senderID', isEqualTo: friendId)
            .where('receiverID', isEqualTo: myID)
            .get();

        if (existingRequestSameIds.docs.isEmpty &&
            existingRequestOppositeIds.docs.isEmpty) {
          // Proceed with adding the friend request
          addFriend(myID, friendId);
        } else {
          // Handle cases where the friend request already exists or users are already friends
          // TODO: Add appropriate UI feedback, e.g., showing a message to the user
          print('Friend request already exists or users are already friends.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Zaproszenie do znajomych już istnieje lub użytkownicy są już znajomymi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle case where the user with the provided email does not exist
        // TODO: Add appropriate UI feedback, e.g., showing a message to the user
        print('User with email $email does not exist.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Użytkownik o adresie e-mail $email nie istnieje.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error finding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd logowania: $e'),
          backgroundColor: Colors.red,
        ),
      );
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