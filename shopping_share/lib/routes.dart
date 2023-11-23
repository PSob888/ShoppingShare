import 'package:flutter/material.dart';
import 'package:shopping_share/screens/home_screen.dart';
import 'package:shopping_share/screens/register_screen.dart';
import 'package:shopping_share/screens/main_screen.dart';

class MyRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/registersuccess':
        //return MaterialPageRoute(builder: (_) => const RegisterSuccess());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case '/ship-deployment':
        //return MaterialPageRoute(builder: (_) => const ShipPlacementScreen());
      // case '/game':
      //   return MaterialPageRoute(builder: (_) => const GameScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
