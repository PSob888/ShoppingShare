import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//TODO: move this to AuthProvider.dart
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> registerUser(
    String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': email,
    });
    Navigator.pushNamed(context, '/registersuccess');
  } catch (e) {
    if (e is FirebaseAuthException) {
      if (e.code == 'weak-password') {
        // Handle weak password error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd rejestracji: Za słabe hasło'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        // Handle email already in use error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Błąd rejestracji: Istnieje już konto z takim emailem'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'invalid-email') {
        // Handle invalid email format error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd rejestracji: Źle sformatowany email'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Handle other types of errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd rejestracji: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Handle other types of errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd rejestracji: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers to free up resources when the widget is removed
    emailController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Color(0xFF446792); // Define the button color
    final buttonHeight = 50.0; // Define the button height

    return Scaffold(
      backgroundColor: Color(0xFF141D26),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Your smaller logo or image
              Image.asset('assets/images/cart.png',
                  width: 150,
                  height:
                      150), // Replace with the actual path to your smaller logo image.
              Text(
                'Shopping Share',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Add some spacing
              SizedBox(height: 60),

              // Email field
              FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  height: buttonHeight, // Set the input field height
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(217, 217, 217, 1),
                      hintText: 'Email',
                    ),
                  ),
                ),
              ),

              // Add spacing between email and nickname fields
              SizedBox(height: 20),

              // Nickname field
              FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  height: buttonHeight, // Set the input field height
                  child: TextField(
                    controller: nicknameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(217, 217, 217, 1),
                      hintText: 'Haslo',
                    ),
                  ),
                ),
              ),

              // Add spacing between nickname and password fields
              SizedBox(height: 20),

              // Registration button
              FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // Shadow position
                      ),
                    ],
                  ),
                  height: buttonHeight, // Set the button height
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle the registration button press
                      String email = emailController.text;
                      String password = nicknameController.text;

                      //dodac checkowanie czy hasla sa takie same itd.

                      registerUser(email, password, context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(buttonColor),
                    ),
                    child: Text('Register', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
