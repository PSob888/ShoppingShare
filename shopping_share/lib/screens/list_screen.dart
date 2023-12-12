import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/theme.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';

class ListScreen extends StatelessWidget {
  final String listName;
  final String listUid;
  final String amountSpent;

  const ListScreen({Key? key, required this.listName, required this.listUid, required this.amountSpent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listName)),
      bottomNavigationBar: BottomBar(currentIndex: 1),
      body: ListStream(listUid: listUid, amountSpent: amountSpent),
      backgroundColor: backgroundColor,
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.addToShoppingList(context, listUid),
      ),
    );
  }
}

class ListStream extends StatelessWidget {
  MyAuthProvider _authProvider = MyAuthProvider();
  final String listUid;
  final String amountSpent;

  ListStream({Key? key, required this.listUid, required this.amountSpent}) : super(key: key);

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

        return ListListView(snapshot: snapshot, listUid: listUid, amountSpent: amountSpent);
      },
    );
  }
}

class ListListView extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final String listUid;
  String amountSpent;

  ListListView({Key? key, required this.snapshot, required this.listUid, required this.amountSpent}) : super(key: key);

  @override
  _ListListViewState createState() => _ListListViewState();
}

class _ListListViewState extends State<ListListView> {
  Map<String, bool> itemCheckedState = {};
  bool promptShown = false;
  TextEditingController amountController = TextEditingController();
  String? enteredAmountSpent;

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> shoppingLists = widget.snapshot.data!.docs;

    // Check if all items are bought
    bool allItemsBought = shoppingLists.every((item) => item['bought'] == true);

    // Check if the amount spent exists in Firebase

    if (allItemsBought && !promptShown && shoppingLists.length > 0) {
      promptShown = true;
      showAmountPrompt(context);
    }
    
    return Column(
    children: [
      if(widget.amountSpent != '0')
        Text("Wydałeś: ${widget.amountSpent} zł", 
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),),
         // Add "haha" text here
      Expanded(
        child: ListView.builder(
          itemCount: shoppingLists.length,
          itemBuilder: (context, index) {
            String itemName = shoppingLists[index]['name'] ?? '';
            String itemQuantity = shoppingLists[index]['quantity'] ?? '0';
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
                  FirebaseFirestore.instance.collection('lists').doc(widget.listUid).update({
                    'itemAmount': FieldValue.increment(-1),
                  });
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
                  child: ListTile(
                    tileColor: primaryColor,
                    title: Row(
                      children: [
                        Image.network('https://source.unsplash.com/random/?$itemName', width: 50, height: 50), // Adjust width and height as needed
                        SizedBox(width: 16), // Add spacing between image and text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                            ),
                            Text(
                              'Sztuk: $itemQuantity\nOpis: $itemDescription',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Checkbox(
                      activeColor: checkboxColor,
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          itemCheckedState[documentId] = value!;
                          // Update the 'bought' field in Firestore based on the checkbox state
                          FirebaseFirestore.instance.collection('lists').doc(widget.listUid).collection('items').doc(documentId).update({
                            'bought': value,
                          });
                          // Check if last item checked and show popup
                          bool allItemsBought = false;
                          int a = 0;
                          for (var item in shoppingLists) {
                            a++;
                          }
                          if (a == shoppingLists.length) {
                            allItemsBought = true;
                          }
                          print(allItemsBought);
                          print(value);
                          if (allItemsBought && shoppingLists.length > 0 && value == true) {
                            promptShown = true;
                            showAmountPrompt(context);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
  }

  Future<void> showAmountPrompt(BuildContext context) async {
  await Future.delayed(Duration.zero);
  String? amountSpent = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Wpisz ile wydałeś'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'PLN'),
          onChanged: (value) {
            // Handle amount change
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                enteredAmountSpent = amountController.text;
              });
              Navigator.of(context).pop(amountController.text);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );

  // Update the amount spent in Firebase
  if (amountSpent != null && amountSpent.isNotEmpty) {
    FirebaseFirestore.instance.collection('lists').doc(widget.listUid).update({
      'amountSpent': amountSpent,
    });
  }
  //update amount spent
  if (amountSpent != null && amountSpent.isNotEmpty)
    widget.amountSpent = amountSpent;
}
}