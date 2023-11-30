import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_share/theme.dart';
import 'package:shopping_share/providers/AuthProvider.dart';
import 'package:shopping_share/widgets/bottom_navbar.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button.dart';
import 'package:shopping_share/widgets/floating_buttons/floating_button_callbacks.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomBar(currentIndex: 1),
      body: FriendListStream(),
      backgroundColor: backgroundColor,
      floatingActionButton: CustomFAB(
        onPressed: () => FABCallbacks.addFriend(context),
      ),
    );
  }
}

class FriendListStream extends StatelessWidget {
  AuthProvider _authProvider = AuthProvider();
  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(
              'friend_reqs') // TODO: add accepted friends from users collection - friends array
          .where('receiverID', isEqualTo: userId)
          .where('status', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If the data is available, build the list view
        return FriendListView(snapshot: snapshot);
      },
    );
  }
}

class FriendListView extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;

  const FriendListView({Key? key, required this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract shopping lists from the snapshot
    List<DocumentSnapshot> friendList = snapshot.data!.docs;

    return ListView.builder(
      itemCount: friendList.length,
      itemBuilder: (context, index) {
        // Extract data for each shopping list
        Map<String, dynamic> friend =
            friendList[index].data() as Map<String, dynamic>;
        return FriendListCard(friend: friend);
      },
    );
  }
}

class FriendListCard extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendListCard({Key? key, required this.friend}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(friend['senderID']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.check), onPressed: () {}),
            IconButton(icon: Icon(Icons.close), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
