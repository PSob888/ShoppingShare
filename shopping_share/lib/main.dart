import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';

import 'routes.dart';
import 'package:shopping_share/theme.dart';
import 'package:provider/provider.dart';
import 'package:shopping_share/providers/MyAuthProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  Permission.notification.request();
  Permission.location.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAuthProvider(),
        child: MaterialApp(
          title: 'ShoppingShare',
          debugShowCheckedModeBanner: false,
          theme: themeData(),
          // initialRoute: '/shopping_lists',
          onGenerateRoute:
              MyRouter.generateRoute, // class containing app's routes
        ));
  }
}
