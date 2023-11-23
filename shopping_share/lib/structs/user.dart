import 'dart:ffi';

class User {
  final String id;
  final String email;
  final List<String> friends;

  User({
    required this.id,
    required this.email,
    List<String>? friends,
  }) : friends = friends ?? []; // Initialize friends with an empty list if null

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'friends': friends,
    };
  }
}
