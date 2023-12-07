import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';


class ListScreen extends StatelessWidget {
  final String listName;

  const ListScreen({Key? key, required this.listName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
        backgroundColor: Colors.grey, // Set the background color here
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      body: ListView(
        // Add your list items here
      ),
      backgroundColor: backgroundColor, // Set the background color here
      floatingActionButton: CustomFAB(
        onPressed: () {
          // Add your FAB callback for the ListScreen here
        },
      ),
    );
  }
}