import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static User? _user;
  Map<String, dynamic>? _userData;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  String? getUserId() {
    return _user?.uid;
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Fetch additional user data from Firestore
      await _fetchUserData();

      notifyListeners();
    } catch (e) {
      // Handle login failure
      print('Błąd logowania: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd logowania: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(_user!.uid).get();

        _userData = userSnapshot.data() as Map<String, dynamic>;
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }
}
