import 'package:flutter/material.dart';
import 'package:shopping_share/screens/account_screen.dart';
import 'package:shopping_share/screens/home_screen.dart';
import 'package:shopping_share/screens/register_screen.dart';
import 'package:shopping_share/screens/main_screen.dart';
import 'package:shopping_share/screens/settings_screen.dart';
import 'package:shopping_share/screens/shopping_list_screen.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case '/account':
        return MaterialPageRoute(builder: (_) => AccountScreen());
      case '/shopping_lists':
        return MaterialPageRoute(builder: (_) => const ShoppingListsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
