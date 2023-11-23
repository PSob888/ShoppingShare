import 'dart:ffi';


class User {
  final String id;
  final String email;

  User({required this.id, 
  required this.email,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
    };
  }
}