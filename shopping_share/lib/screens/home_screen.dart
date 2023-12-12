import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shopping_share/providers/AuthProvider.dart' as AuthProvider;

final FirebaseAuth _auth = FirebaseAuth.instance;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the controllers to free up resources when the widget is removed
    emailController.dispose();
    passwordController.dispose();
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
              // Your logo or image
              Image.asset('assets/images/cart.png',
                  width: 150,
                  height:
                      150), // Replace with the actual path to your logo image.
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

              // Add spacing between email and password fields
              SizedBox(height: 20),

              // Password field
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
                    controller: passwordController,
                    obscureText: true, // To hide the password
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromRGBO(217, 217, 217, 1),
                      hintText: 'Haslo',
                    ),
                  ),
                ),
              ),

              // Add spacing between the input fields and buttons
              SizedBox(height: 20),

              // Login button
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
                    onPressed: () async {
                      // Get the text from the email and password fields
                      String email = emailController.text;
                      String password = passwordController.text;

                      // You can now use the email and password variables as needed.
                      AuthProvider.AuthProvider authProvider =
                          Provider.of<AuthProvider.AuthProvider>(context,
                              listen: false);

                      await authProvider.signInWithEmailAndPassword(
                          email, password, context);

                      if (authProvider.user != null) {
                        Navigator.pushNamed(context, '/shopping_lists');
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(buttonColor),
                    ),
                    child: Text('Zaloguj', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),

              // Add spacing between the buttons
              SizedBox(height: 20),

              Text(
                'Nie masz konta?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              TextButton(
                child: const Text(
                  'Zarejestruj się',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () async {
                  debugPrint("Register button pressed");
                  Navigator.pushNamed(context, "/register");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
