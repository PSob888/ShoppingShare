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
      body: Column(
        children: [
          // Display friend requests and friends
          Expanded(
            child: FriendListStream(),
          ),
          // Add space between the two lists
          SizedBox(height: 16),
          // TODO: Display the list of accepted friends here using FriendListStream or another appropriate widget
        ],
      ),
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
          .collection('friend_reqs')
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
    List<DocumentSnapshot> friendList = snapshot.data!.docs;

    return ListView.builder(
      itemCount: friendList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item =
            friendList[index].data() as Map<String, dynamic>;

        bool isFriendRequest = item['status'] == false;

        return FriendListTile(
          isFriendRequest: isFriendRequest,
          friendData: item,
        );
      },
    );
  }
}

class FriendListTile extends StatelessWidget {
  final bool isFriendRequest;
  final Map<String, dynamic> friendData;

  const FriendListTile({
    Key? key,
    required this.isFriendRequest,
    required this.friendData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: FutureBuilder<String>(
          future: getEmailFromId(friendData['senderID']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String email = snapshot.data ?? 'Unknown';
              return Text(email);
            }
          },
        ),
        trailing: isFriendRequest
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      acceptFriendRequest(
                          friendData['senderID'], friendData['receiverID']);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      denyFriendRequest(
                          friendData['senderID'], friendData['receiverID']);
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    try {
      QuerySnapshot friendRequests = await FirebaseFirestore.instance
          .collection('friend_reqs')
          .where('senderID', isEqualTo: senderId)
          .where('receiverID', isEqualTo: receiverId)
          .get();

      for (QueryDocumentSnapshot doc in friendRequests.docs) {
        doc.reference.update({'status': true});
      }
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> denyFriendRequest(String senderId, String receiverId) async {
    try {
      QuerySnapshot friendRequests = await FirebaseFirestore.instance
          .collection('friend_reqs')
          .where('senderID', isEqualTo: senderId)
          .where('receiverID', isEqualTo: receiverId)
          .get();

      for (QueryDocumentSnapshot doc in friendRequests.docs) {
        doc.reference.delete();
      }
    } catch (e) {
      print('Error denying friend request: $e');
    }
  }

  Future<String> getEmailFromId(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['email'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error fetching email from ID: $e');
      return 'Unknown';
    }
  }
}
