import 'dart:ffi';


class Item {
  final String list_id;
  final String name;
  final String description;
  final String required;
  final String amount;

  Item({required this.list_id,
  required this.name, 
  required this.description,
  required this.required,
  required this.amount,});

  Map<String, dynamic> toMap() {
    return {
      'list_id': list_id,
      'name': name,
      'description': description,
      'required': required,
      'amount': amount,
    };
  }
}