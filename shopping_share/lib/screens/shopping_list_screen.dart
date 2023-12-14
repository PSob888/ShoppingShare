import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';
import 'package:intl/intl.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.grey,
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
                        primary:
                            selectedButton == "my" ? Colors.blue : Colors.grey,
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
                        primary: selectedButton == "shared"
                            ? Colors.blue
                            : Colors.grey,
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
      ),
      backgroundColor: backgroundColor,
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.createNewShoppingList(context),
      ),
    );
  }
}

class ShoppingListsStream extends StatelessWidget {
  MyAuthProvider _authProvider = MyAuthProvider();
  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .where('user_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ShoppingListsListView(snapshot: snapshot);
      },
    );
  }
}

class ShoppingListsListView extends StatelessWidget {
  MyAuthProvider _authProvider = MyAuthProvider();
  final AsyncSnapshot<QuerySnapshot> snapshot;
  Offset? _tapPosition;

  ShoppingListsListView({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> shoppingLists = snapshot.data!.docs;

    return ListView.builder(
      itemCount: shoppingLists.length,
      itemBuilder: (context, index) {
        String listName = shoppingLists[index]['name'] ?? '';
        Timestamp createdAtTimestamp =
            shoppingLists[index]['created_at'] ?? Timestamp.now();
        DateTime createdAt = createdAtTimestamp.toDate();
        int itemAmount = shoppingLists[index]['itemAmount'] ?? 0;
        bool isDone = shoppingLists[index]['isDone'] ?? false;
        String documentId = shoppingLists[index].id;
        String amountSpend = shoppingLists[index]['amountSpent'];

        return GestureDetector(
          onTap: () {
            // Navigate to the list screen
            Navigator.pushNamed(context, '/list', arguments: {
              'parameter1': listName,
              'parameter2': documentId,
              'parameter3': amountSpend
            });
          },
          onLongPress: () {
            _showContextMenu(context, documentId);
          },
          onTapDown: (TapDownDetails details) {
            _tapPosition = details.globalPosition;
          },
          child: Dismissible(
            key: Key(documentId),
            onDismissed: (direction) {
              FirebaseFirestore.instance
                  .collection('lists')
                  .doc(documentId)
                  .delete();
              FirebaseFirestore.instance
                  .collection('lists')
                  .doc(documentId)
                  .delete();
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
                title: Text(
                  listName,
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Utworzono: ${_formatDate(createdAt)}',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'liczba produktów: $itemAmount',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Status: ${isDone ? "Zakończona" : "Trwająca"}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showContextMenu(BuildContext context, String documentId) async {
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox?;

    if (overlay is RenderBox && _tapPosition != null) {
      await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition! &
                const Size(40,
                    40), // Mniejszy prostokąt, w którym nastąpiło naciśnięcie
            Offset.zero & overlay.size // Pełny ekran
            ),
        items: <PopupMenuEntry>[
          PopupMenuItem(
            value: 'clone',
            child: Text('Klonuj'),
          ),
          PopupMenuItem(
            value: 'share',
            child: Text('Udostępnij'),
          ),
        ],
      ).then((value) {
        // Akcje po wyborze opcji z menu
        if (value == 'clone') {
          print('Clone clicked');
          // todo Logika klonowania
          //_cloneItem();
        } else if (value == 'share') {
          print('Share clicked');
          _shareShoppingList(documentId);
          // print documentId;
        }
      });
    }
  }

  void _shareShoppingList(String documentId) async {
    print('Udostępniam listę o ID: $documentId');
    String? userId = _authProvider.user?.uid;

    if (userId == null) {
      print('Użytkownik nie jest zalogowany.');
      return;
    }

    // Pobierz listę ID znajomych
    QuerySnapshot friendsQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friends')
        .get();

    // Przechodzimy przez wszystkich znajomych
    for (var friend in friendsQuery.docs) {
      String friendUserId =
          friend['friendID']; // zakładamy, że pole nazywa się 'userId'

      // Pobierz dane użytkownika po ID
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUserId)
          .get();

      String? friendEmail =
          userDoc['email']; // zakładamy, że pole nazywa się 'email'
      if (friendEmail != null) {
        print('Znajomy ID: $friendUserId, email: $friendEmail');
      } else {
        print('Nie znaleziono emaila dla znajomego o ID: $friendUserId');
      }
    }
  }

  String _formatDate(DateTime date) {
    // Format the DateTime as needed
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
