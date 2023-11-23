import 'package:flutter/material.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 2),
      body: Center(child: Text('Settings')),
    );
  }
}
