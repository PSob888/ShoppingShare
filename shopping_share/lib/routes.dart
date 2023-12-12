import 'package:flutter/material.dart';
import 'package:shopping_share/screens/account_screen.dart';
import 'package:shopping_share/screens/home_screen.dart';
import 'package:shopping_share/screens/register_screen.dart';
import 'package:shopping_share/screens/main_screen.dart';
import 'package:shopping_share/screens/settings_screen.dart';
import 'package:shopping_share/screens/shopping_list_screen.dart';
import 'package:shopping_share/screens/register_success.dart';
import 'package:shopping_share/screens/list_screen.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract parameters if available
    final Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/registersuccess':
        return MaterialPageRoute(builder: (_) => const RegisterSuccess());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case '/account':
        return MaterialPageRoute(builder: (_) => AccountScreen());
      case '/shopping_lists':
        return MaterialPageRoute(builder: (_) => const ShoppingListsScreen());
      case '/list':
        // Check if parameters are available
        if (arguments != null) {
          // Access parameters and pass them to the ListScreen widget
          final String parameter1 = arguments['parameter1'];
          final String parameter2 = arguments['parameter2'];
          return MaterialPageRoute(builder: (_) => ListScreen(listName: parameter1, listUid: parameter2));
        } else {
          // If no parameters are available, create a default ListScreen
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}