import 'package:flutter/material.dart';

import 'package:shopping_share/widgets/floating_buttons/popup_add_to_list.dart';
import 'package:shopping_share/widgets/floating_buttons/popup_create_list.dart';
import 'package:shopping_share/widgets/floating_buttons/popup_add_friend.dart';

class FABCallbacks {
  static void addToShoppingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddToListPopup();
      },
    );
  }

  static void createNewShoppingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CreateNewShoppingListPopup();
      },
    );
  }

  static void addFriend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AddFriendPopup();
      },
    );
  }
}
