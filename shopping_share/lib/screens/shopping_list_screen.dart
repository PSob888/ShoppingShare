import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';

import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';

class ShoppingListsScreen extends StatefulWidget {
  const ShoppingListsScreen({Key? key}) : super(key: key);

  @override
  _ShoppingListsScreenState createState() => _ShoppingListsScreenState();
}

class _ShoppingListsScreenState extends State<ShoppingListsScreen> {
  String selectedButton = "my";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(currentIndex: 0),
      body: Column(
        children: [
          Container(
            color: Colors.grey, // Set the background color here
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = "my";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == "my" ? Colors.blue : Colors.grey,
                    ),
                    child: Text("My"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedButton = "shared";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedButton == "shared" ? Colors.blue : Colors.grey,
                    ),
                    child: Text("Shared"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ShoppingListsStream(),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.createNewShoppingList(context),
      ),
    );
  }
}


class ShoppingListsStream extends StatelessWidget {
  AuthProvider _authProvider = AuthProvider();
  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('lists').where('user_id', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If the data is available, build the list view
        return ShoppingListsListView(snapshot: snapshot);
      },
    );
  }
}

class ShoppingListsListView extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;

  const ShoppingListsListView({Key? key, required this.snapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract shopping lists from the snapshot
    List<DocumentSnapshot> shoppingLists = snapshot.data!.docs;

    return ListView.builder(
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        // Extract data for each shopping list
        String listName = shoppingLists[index]['name'] ?? '';
        String documentId = shoppingLists[index].id;

        return Dismissible(
          key: Key(documentId),
          onDismissed: (direction) {
            // Delete the item from Firestore when dismissed
            FirebaseFirestore.instance.collection('lists').doc(documentId).delete();
          },
          background: Container(
            color: Color(0xFF8C2A35), // Background color when swiping
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(8.0), // Add margins to every side
            child: ListTile(
              tileColor: primaryColor,
              title: Text(
                listName,
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ),
          ),
        );
      },
    );
  }
}