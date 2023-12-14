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
          SizedBox(height: 36),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Znajomi',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FriendListStream(isFriendRequest: false),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Zaproszenia do znajomych',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FriendListStream2(isFriendRequest: true),
          ),
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
  final bool isFriendRequest;

  FriendListStream({required this.isFriendRequest});

  AuthProvider _authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid ?? '';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Filter out accepted friend requests if displaying the "Zaproszenia do znajomych" list
        List<QueryDocumentSnapshot> filteredList = snapshot.data!.docs
            .toList();

        if (filteredList.isEmpty) {
          return Center(
              child: Text(
                  'No ${isFriendRequest ? 'friend requests' : 'accepted friends'} available.'));
        }

        // If the data is available, build the list view
        return FriendListView(
          snapshot: snapshot,
          isFriendRequest: isFriendRequest,
          filteredList: filteredList,
        );
      },
    );
  }
}

class FriendListView extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final bool isFriendRequest;
  final List<QueryDocumentSnapshot> filteredList;

  const FriendListView({
    Key? key,
    required this.snapshot,
    required this.isFriendRequest,
    required this.filteredList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item =
            filteredList[index].data() as Map<String, dynamic>;

        return FriendListTile(
          friendData: item,
        );
      },
    );
  }
}

class FriendListTile extends StatelessWidget {
  final Map<String, dynamic> friendData;

  const FriendListTile({
    Key? key,
    required this.friendData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = AuthProvider();
    String currentUserId = _authProvider.user?.uid ?? '';

        return Card(
      child: ListTile(
        title: FutureBuilder<String>(
          future: getEmailFromId2(friendData['friendID']),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeFriend2(friendData['senderID'], friendData['receiverID']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> removeFriend2(String userId, String friendId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .where('friendID', isEqualTo: friendId)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .where('friendID', isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // to tez zmieniam, pozdro
      // await removeFriendFromUser(userId, friendId);
      // await removeFriendFromUser(friendId, userId);

      // QuerySnapshot friendRequests = await FirebaseFirestore.instance
      //     .collection('friend_reqs')
      //     .where('senderID', isEqualTo: userId)
      //     .where('receiverID', isEqualTo: friendId)
      //     .get();

      // for (QueryDocumentSnapshot doc in friendRequests.docs) {
      //   doc.reference.delete();
      // }

      // friendRequests = await FirebaseFirestore.instance
      //     .collection('friend_reqs')
      //     .where('senderID', isEqualTo: friendId)
      //     .where('receiverID', isEqualTo: userId)
      //     .get();

      // for (QueryDocumentSnapshot doc in friendRequests.docs) {
      //   doc.reference.delete();
      // }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

    Future<String> getEmailFromId2(String userId) async {
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

class FriendListStream2 extends StatelessWidget {
  final bool isFriendRequest;

  FriendListStream2({required this.isFriendRequest});

  AuthProvider _authProvider = AuthProvider();

  @override
  Widget build(BuildContext context) {
    String? userId = _authProvider.user?.uid ?? '';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_reqs')
          .where(isFriendRequest ? 'receiverID' : 'status',
              isEqualTo: isFriendRequest ? userId : true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Filter out accepted friend requests if displaying the "Zaproszenia do znajomych" list
        List<QueryDocumentSnapshot> filteredList = snapshot.data!.docs
            .where((doc) => isFriendRequest ? doc['status'] == false : true)
            .toList();

        if (filteredList.isEmpty) {
          return Center(
              child: Text(
                  'No ${isFriendRequest ? 'friend requests' : 'accepted friends'} available.'));
        }

        // If the data is available, build the list view
        return FriendListView2(
          snapshot: snapshot,
          isFriendRequest: isFriendRequest,
          filteredList: filteredList,
        );
      },
    );
  }
}

class FriendListView2 extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final bool isFriendRequest;
  final List<QueryDocumentSnapshot> filteredList;

  const FriendListView2({
    Key? key,
    required this.snapshot,
    required this.isFriendRequest,
    required this.filteredList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item =
            filteredList[index].data() as Map<String, dynamic>;

        bool isFriendRequestItem = item['status'] == false;

        return FriendListTile2(
          isFriendRequest: isFriendRequestItem,
          friendData: item,
        );
      },
    );
  }
}

class FriendListTile2 extends StatelessWidget {
  final bool isFriendRequest;
  final Map<String, dynamic> friendData;

  const FriendListTile2({
    Key? key,
    required this.isFriendRequest,
    required this.friendData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = AuthProvider();
    String currentUserId = _authProvider.user?.uid ?? '';

    return Card(
      child: ListTile(
        title: FutureBuilder<String>(
          future: getEmailFromId(
            friendData['senderID'] == currentUserId
                ? friendData['receiverID']
                : friendData['senderID'],
          ),
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
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      removeFriend(
                          friendData['senderID'], friendData['receiverID']);
                    },
                  ),
                ],
              ),
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

      await addFriendToUser(senderId, receiverId);
      //await addFriendToUser(receiverId, senderId); tera useless po zmianach
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  Future<void> addFriendToUser(String userId, String friendId) async {
    try {
      CollectionReference friendsCollectionUser = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('friends');

      await friendsCollectionUser.add({
        'friendID': friendId,
      });

      CollectionReference friendsCollectionFriend = FirebaseFirestore.instance
      .collection('users')
      .doc(friendId)
      .collection('friends');

      await friendsCollectionFriend.add({
        'friendID': userId,
      });

      //nw co to ma robic, ale zrobie wyzej swoja wersje pozdrawiam :)
      // DocumentReference userRef =
      //     FirebaseFirestore.instance.collection('users').doc(userId);

      // DocumentSnapshot userSnapshot = await userRef.get();

      // if (userSnapshot.exists) {
      //   List<String> friends = List<String>.from(
      //       (userSnapshot.data() as Map<String, dynamic>?)?['friends'] ?? []);

      //   if (!friends.contains(friendId)) {
      //     friends.add(friendId);

      //     await userRef.update({'friends': friends});
      //   }
      // } else {
      //   await userRef.set({
      //     'friends': [friendId]
      //   }, SetOptions(merge: true));
      // }
    } catch (e) {
      print('Error adding friend to user: $e');
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

  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .where('friendID', isEqualTo: friendId)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .where('friendID', isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // to tez zmieniam, pozdro
      // await removeFriendFromUser(userId, friendId);
      // await removeFriendFromUser(friendId, userId);

      // QuerySnapshot friendRequests = await FirebaseFirestore.instance
      //     .collection('friend_reqs')
      //     .where('senderID', isEqualTo: userId)
      //     .where('receiverID', isEqualTo: friendId)
      //     .get();

      // for (QueryDocumentSnapshot doc in friendRequests.docs) {
      //   doc.reference.delete();
      // }

      // friendRequests = await FirebaseFirestore.instance
      //     .collection('friend_reqs')
      //     .where('senderID', isEqualTo: friendId)
      //     .where('receiverID', isEqualTo: userId)
      //     .get();

      // for (QueryDocumentSnapshot doc in friendRequests.docs) {
      //   doc.reference.delete();
      // }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  Future<void> removeFriendFromUser(String userId, String friendId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        List<String> friends = List<String>.from(userSnapshot['friends']);

        if (friends.contains(friendId)) {
          friends.remove(friendId);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'friends': friends});
        }
      }
    } catch (e) {
      print('Error removing friend from user: $e');
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
