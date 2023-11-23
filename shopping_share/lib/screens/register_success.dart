import 'package:flutter/material.dart';

class RegisterSuccess extends StatelessWidget {
  const RegisterSuccess({super.key});

  @override
  Widget build(BuildContext context) {

    final buttonColor = Color(0xFF446792); // Define the button color
    final buttonHeight = 50.0;
    return Scaffold(
      backgroundColor: Color(0xFF141D26), // Set the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Zarejestrowano pomyślnie!",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white, // Text color
              ),
            ),
            SizedBox(height: 20), // Add some spacing between the text and the button
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
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(buttonColor),
                    ),
                    child: Text('Register'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}