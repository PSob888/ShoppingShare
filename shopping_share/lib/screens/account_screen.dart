import 'package:flutter/material.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 1),
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: const Center(
        child: Text('Account'),
      ),
    );
  }
}
