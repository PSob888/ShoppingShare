import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatNewPasswordController = TextEditingController();
  MyAuthProvider authProvider = MyAuthProvider();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    newPasswordController.dispose();
    repeatNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Color(0xFF446792);
    final buttonHeight = 50.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      bottomNavigationBar: BottomBar(currentIndex: 2),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Nowe hasło
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nowe hasło',
              ),
            ),

            SizedBox(height: 20),

            // Powtórz nowe hasło
            TextField(
              controller: repeatNewPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Powtórz nowe hasło',
              ),
            ),

            SizedBox(height: 20),

            // Przycisk zmiany hasła
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () async {
                    // Sprawdź, czy oba pola są wypełnione
                    if (newPasswordController.text.isNotEmpty &&
                        repeatNewPasswordController.text.isNotEmpty) {
                      // Sprawdź, czy nowe hasła są identyczne
                      if (newPasswordController.text ==
                          repeatNewPasswordController.text) {
                        // Zmień hasło
                        try {
                          await _auth.currentUser!
                              .updatePassword(newPasswordController.text);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Sukces'),
                                content:
                                    Text('Hasło zostało pomyślnie zmienione.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Błąd'),
                                content: Text(
                                    'Nie udało się zmienić hasła. Spróbuj ponownie.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        // Wyświetl błąd, jeśli hasła nie są identyczne
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Błąd'),
                              content: Text('Podane hasła nie są identyczne.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      // Wyświetl błąd, jeśli którekolwiek pole jest puste
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Błąd'),
                            content: Text('Wypełnij oba pola.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(buttonColor),
                  ),
                  child: Text('Zmień hasło', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
           // Logout button
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                margin: EdgeInsets.only(top: 20),
                height: buttonHeight,
                decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                child: TextButton(
                  onPressed: () async {
                    // Call the signOut method from your AuthProvider
                    await authProvider.signOut();
                    // Navigate to the login or home screen after logout
                    Navigator.pushReplacementNamed(context, '/login'); // Change '/login' to your desired route
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: Text('Wyloguj', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
