import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';


class ListScreen extends StatelessWidget {
  final String listName;
  final String listUid;

  const ListScreen({Key? key, required this.listName, required this.listUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listName)),
      bottomNavigationBar: BottomBar(currentIndex: 1),
      body: ListStream(listUid: listUid),
      backgroundColor: backgroundColor,
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.addToShoppingList(context, listUid),
      ),
    );
  }
}

class ListStream extends StatelessWidget {
  AuthProvider _authProvider = AuthProvider();
  final String listUid; // Add this line

  ListStream({Key? key, required this.listUid}) : super(key: key); // Add this constructor

  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .doc(listUid)
          .collection('items')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ListListView(snapshot: snapshot, listUid: listUid);
      },
    );
  }
}

class ListListView extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final String listUid;

  const ListListView({Key? key, required this.snapshot, required this.listUid}) : super(key: key);

  @override
  _ListListViewState createState() => _ListListViewState();
}

class _ListListViewState extends State<ListListView> {
  Map<String, bool> itemCheckedState = {};

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> shoppingLists = widget.snapshot.data!.docs;

    return ListView.builder(
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        String itemName = shoppingLists[index]['name'] ?? '';
        String itemQuantity = shoppingLists[index]['quantity'] ?? 0;
        String itemDescription = shoppingLists[index]['description'] ?? '';
        String documentId = shoppingLists[index].id;

        bool isChecked = shoppingLists[index]['bought'] ?? false;

        return GestureDetector(
          onTap: () {
            setState(() {
              itemCheckedState[documentId] = !isChecked;
              // Update the 'bought' field in Firestore based on the checkbox state
              FirebaseFirestore.instance.collection('lists').doc(widget.listUid).collection('items').doc(documentId).update({
                'bought': !isChecked,
              });
            });
          },
          child: Dismissible(
            key: Key(documentId),
            onDismissed: (direction) {
              FirebaseFirestore.instance.collection('lists').doc(widget.listUid).collection('items').doc(documentId).delete();
            },
            background: Container(
              color: Color(0xFF8C2A35),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(8.0),
              child: CheckboxListTile(
                tileColor: primaryColor,
                activeColor: checkboxColor,
                title: Text(
                  itemName,
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                subtitle: Text(
                  'Sztuk: $itemQuantity\nOpis: $itemDescription',
                  style: TextStyle(color: Colors.white),
                ),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    itemCheckedState[documentId] = value!;
                    // Update the 'bought' field in Firestore based on the checkbox state
                    FirebaseFirestore.instance.collection('lists').doc(widget.listUid).collection('items').doc(documentId).update({
                      'bought': value,
                    });
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
          ),
        );
      },
    );
  }
}