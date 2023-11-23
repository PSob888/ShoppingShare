// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCTHmXL7LgrHBI09WxJnq9uHZ5yU4xSuF0',
    appId: '1:345960450978:web:2f691cd4754ee1eb63c0fb',
    messagingSenderId: '345960450978',
    projectId: 'shoppingshare-389f8',
    authDomain: 'shoppingshare-389f8.firebaseapp.com',
    storageBucket: 'shoppingshare-389f8.appspot.com',
    measurementId: 'G-9C1Y3N34LP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQ0N-hJh8m90tjzMHXPkgqBm9jOEWaed4',
    appId: '1:345960450978:android:911fd4fb29b01c8263c0fb',
    messagingSenderId: '345960450978',
    projectId: 'shoppingshare-389f8',
    storageBucket: 'shoppingshare-389f8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkhyXyWcCdlIvEsDJ6zdxVA57YWxupP34',
    appId: '1:345960450978:ios:c0ef7e410840bbe663c0fb',
    messagingSenderId: '345960450978',
    projectId: 'shoppingshare-389f8',
    storageBucket: 'shoppingshare-389f8.appspot.com',
    iosBundleId: 'com.example.shoppingShare',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkhyXyWcCdlIvEsDJ6zdxVA57YWxupP34',
    appId: '1:345960450978:ios:6fbd021ab7e12c8963c0fb',
    messagingSenderId: '345960450978',
    projectId: 'shoppingshare-389f8',
    storageBucket: 'shoppingshare-389f8.appspot.com',
    iosBundleId: 'com.example.shoppingShare.RunnerTests',
  );
}