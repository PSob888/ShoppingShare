import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                      child: Text("My", style: TextStyle(color: Colors.white)),
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
                      child: Text("Shared", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ShoppingListsStream(selectedButton: selectedButton),
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
  final String selectedButton;
  final MyAuthProvider _authProvider = MyAuthProvider();

  ShoppingListsStream({Key? key, required this.selectedButton})
      : super(key: key);

  Stream<List<DocumentSnapshot>> _getSharedListsStream(String? userId) {
    return FirebaseFirestore.instance
        .collection('shared_lists')
        .where('sharedWithUserId',
            isEqualTo:
                FirebaseFirestore.instance.collection('users').doc(userId))
        .snapshots()
        .asyncMap((sharedListSnapshot) async {
      List<DocumentSnapshot> listSnapshots = [];
      for (var sharedListDoc in sharedListSnapshot.docs) {
        DocumentReference listRef = sharedListDoc['listId'];
        DocumentSnapshot listSnapshot = await listRef.get();
        listSnapshots.add(listSnapshot);
      }
      return listSnapshots;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid;
    Stream<List<DocumentSnapshot>> stream;

    if (selectedButton == "my") {
      stream = FirebaseFirestore.instance
          .collection('lists')
          .where('user_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      stream = _getSharedListsStream(userId);
    }

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Możesz dostosować poniższy widok do twoich potrzeb
        return ShoppingListsListView(
          shoppingLists: snapshot.data!,
          selectedButton: selectedButton,
        );
      },
    );
  }
}

class ShoppingListsListView extends StatelessWidget {
  String selectedButton;
  MyAuthProvider _authProvider = MyAuthProvider();
  final List<DocumentSnapshot> shoppingLists;
  Offset? _tapPosition;
  ShoppingListsListView(
      {Key? key, required this.shoppingLists, required this.selectedButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            _showContextMenu(context, documentId, listName, selectedButton);
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
                tileColor: isDone ? primaryColorDarker : primaryColor,
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

  void _showContextMenu(BuildContext context, String documentId,
      String listname, String selectedButton) async {
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox?;

    if (overlay is RenderBox && _tapPosition != null) {
      // Tworzenie dynamicznej listy elementów menu
      List<PopupMenuEntry<String>> menuItems = [];

      // Zawsze dodawaj opcję 'Klonuj'
      menuItems.add(
        PopupMenuItem(
          value: 'clone',
          child: Text('Klonuj'),
        ),
      );

      // Dodaj opcję 'Udostępnij', tylko jeśli selectedButton == 'my'
      if (selectedButton == 'my') {
        menuItems.add(
          PopupMenuItem(
            value: 'share',
            child: Text('Udostępnij'),
          ),
        );
      }

      // Wyświetl menu
      await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition! & const Size(40, 40), Offset.zero & overlay.size),
        items: menuItems,
      ).then((value) {
        // Obsługa wyboru z menu
        if (value == 'clone') {
          // Logika klonowania
        } else if (value == 'share') {
          _shareShoppingList(context, documentId, listname);
        }
      });
    }
  }
  // void _showContextMenu(
  //     BuildContext context, String documentId, String listname) async {
  //   final RenderBox? overlay =
  //       Overlay.of(context)?.context.findRenderObject() as RenderBox?;

  //   if (overlay is RenderBox && _tapPosition != null) {
  //     await showMenu(
  //       context: context,
  //       position: RelativeRect.fromRect(
  //           _tapPosition! &
  //               const Size(40,
  //                   40), // Mniejszy prostokąt, w którym nastąpiło naciśnięcie
  //           Offset.zero & overlay.size // Pełny ekran
  //           ),
  //       items: <PopupMenuEntry>[
  //         PopupMenuItem(
  //           value: 'clone',
  //           child: Text('Klonuj'),
  //         ),
  //         PopupMenuItem(
  //           value: 'share',
  //           child: Text('Udostępnij'),
  //         ),
  //       ],
  //     ).then((value) {
  //       // Akcje po wyborze opcji z menu
  //       if (value == 'clone') {
  //         print('Clone clicked');
  //         // todo Logika klonowania
  //         //_cloneItem();
  //       } else if (value == 'share') {
  //         print('Share clicked');
  //         _shareShoppingList(context, documentId, listname);
  //         // print documentId;
  //       }
  //     });
  //   }
  // }

  void _shareShoppingList(
      BuildContext context, String documentId, String listname) async {
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

    List<Map<String, String>> friendsList = [];

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
        friendsList.add({'friendID': friendUserId, 'email': friendEmail});
      } else {
        print('Nie znaleziono emaila dla znajomego o ID: $friendUserId');
      }
    }

    _showShareDialog(context, listname, documentId, friendsList);
  }

  void _showShareDialog(BuildContext context, String listName,
      String documentId, List<Map<String, String>> friends) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Udostępianie\n$listName'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Lista znajomych',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(friends[index]['email'] ?? 'Brak emaila'),
                        trailing: IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            // Logika udostępniania listy znajomemu
                            _shareWithFriend(documentId,
                                friends[index]['friendID'], listName);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _shareWithFriend(String documentId, String? friendId, String listName) {
    if (friendId != null) {
      print('Udostępnianie listy "$listName" znajomemu o ID: $friendId');
      shareList(documentId, _authProvider.user!.uid, friendId);
      showToast("Znajomy został dodany do listy $listName", duration: 2);
    }
  }

  Future<void> shareList(
      String listId, String ownerId, String sharedWithUserId) async {
    DocumentReference listRef =
        FirebaseFirestore.instance.collection('lists').doc(listId);
    DocumentReference ownerRef =
        FirebaseFirestore.instance.collection('users').doc(ownerId);
    DocumentReference sharedWithUserRef =
        FirebaseFirestore.instance.collection('users').doc(sharedWithUserId);

    await FirebaseFirestore.instance.collection('shared_lists').add({
      'listId': listRef,
      'ownerId': ownerRef,
      'sharedWithUserId': sharedWithUserRef,
    });
  }

  Future<List<DocumentSnapshot>> getSharedLists(String userId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    var querySnapshot = await FirebaseFirestore.instance
        .collection('shared_lists')
        .where('sharedWithUserId', isEqualTo: userRef)
        .get();

    return querySnapshot.docs;
  }

  Future<void> unshareList(String sharedListDocumentId) async {
    await FirebaseFirestore.instance
        .collection('shared_lists')
        .doc(sharedListDocumentId)
        .delete();
  }

  void showToast(String msg, {int duration = 3}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: duration,
        backgroundColor: Colors.grey[800],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  String _formatDate(DateTime date) {
    // Format the DateTime as needed
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
