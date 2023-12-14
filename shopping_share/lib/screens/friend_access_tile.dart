import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';

class FriendAccessTile extends StatefulWidget {
  final String friendId;
  final String documentId;
  final String friendEmail;

  FriendAccessTile({
    Key? key,
    required this.friendId,
    required this.documentId,
    required this.friendEmail,
  }) : super(key: key);

  @override
  _FriendAccessTileState createState() => _FriendAccessTileState();
}

class _FriendAccessTileState extends State<FriendAccessTile> {
  MyAuthProvider _authProvider = MyAuthProvider();
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    bool access = await hasAccess(widget.friendId, widget.documentId);
    setState(() {
      _hasAccess = access;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.friendEmail),
      trailing: IconButton(
        icon: Icon(_hasAccess ? Icons.lock_open : Icons.lock),
        onPressed: () {
          toggleAccess(widget.friendId, widget.documentId, _hasAccess)
              .then((_) => _checkAccess()); // Odśwież stan po zmianie dostępu
        },
      ),
    );
  }

  Future<void> unshareList(String friendId, String listId) async {
    // Najpierw znajdź dokument na podstawie friendId i listId
    var querySnapshot = await FirebaseFirestore.instance
        .collection('shared_lists')
        .where('sharedWithUserId',
            isEqualTo:
                FirebaseFirestore.instance.collection('users').doc(friendId))
        .where('listId',
            isEqualTo:
                FirebaseFirestore.instance.collection('lists').doc(listId))
        .where('ownerId',
            isEqualTo: FirebaseFirestore.instance
                .collection('users')
                .doc(_authProvider.user!.uid))
        .get();

    // Jeśli dokument istnieje, usuń go
    for (var doc in querySnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('shared_lists')
          .doc(doc.id)
          .delete();
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

  Future<void> toggleAccess(
      String friendId, String listId, bool currentlyHasAccess) async {
    if (currentlyHasAccess) {
      await unshareList(friendId, listId);
      showToast("Znajomy został usunięty z listy", duration: 2);
    } else {
      await shareList(listId, _authProvider.user!.uid, friendId);
      showToast("Znajomy został dodany do listy", duration: 2);
    }
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

  // Funkcja do sprawdzania, czy znajomy ma dostęp do listy
  Future<bool> hasAccess(String friendId, String listId) async {
    var sharedListSnapshot = await FirebaseFirestore.instance
        .collection('shared_lists')
        .where('sharedWithUserId',
            isEqualTo:
                FirebaseFirestore.instance.collection('users').doc(friendId))
        .where('listId',
            isEqualTo:
                FirebaseFirestore.instance.collection('lists').doc(listId))
        .get();

    return sharedListSnapshot.docs.isNotEmpty;
  }
}
