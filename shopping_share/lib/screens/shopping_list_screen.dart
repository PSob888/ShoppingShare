import 'package:flutter/material.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      body: const Center(child: Text('Shopping Lists')),
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.createNewShoppingList(context),
      ),
    );
  }
}
