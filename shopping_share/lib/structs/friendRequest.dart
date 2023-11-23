import 'dart:ffi';

class FriendRequest {
  final String senderID;
  final String receiverID;
  final Bool status;

  FriendRequest({
    required this.senderID,
    required this.receiverID,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'status': status,
    };
  }
}
