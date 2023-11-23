import 'package:flutter/material.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 0),
      body: Center(child: Text('Shopping Lists')),
    );
  }
}
