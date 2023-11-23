import 'dart:ffi';

class ShoppingList {
  final String user_id;
  final String name;
  final DateTime created_at;
  final String itemAmount;
  final Bool isDone; 

  ShoppingList({required this.user_id,
  required this.name,
  required this.created_at,
  required this.itemAmount,
  required this.isDone,});

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'name': name,
      'created_at': created_at,
      'itemAmount': itemAmount,
      'isDone': isDone,
    };
  }
}