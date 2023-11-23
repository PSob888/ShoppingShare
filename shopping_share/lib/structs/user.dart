import 'dart:ffi';


class User {
  final String id;
  final String nickname;
  final String points;
  final Bool isAvailable;
  final Bool isConnected;

  User({required this.id, 
  required this.nickname, 
  required this.points, 
  required this.isAvailable, 
  required this.isConnected,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nickname': nickname,
      'points': points,
      'isAvailable': isAvailable,
      'isConnected': isConnected,
    };
  }
}