// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBhT0gC6t9TblT71RBBaQQa3CQ80DWtA-I',
    appId: '1:851697693723:web:1bf1b625fb02ffb4d234be',
    messagingSenderId: '851697693723',
    projectId: 'connexus-hackfest24',
    authDomain: 'connexus-hackfest24.firebaseapp.com',
    storageBucket: 'connexus-hackfest24.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMbOlN0hl3j7X02_53flKAZcOPOPyFPTY',
    appId: '1:851697693723:android:0d7d204a919f299ed234be',
    messagingSenderId: '851697693723',
    projectId: 'connexus-hackfest24',
    storageBucket: 'connexus-hackfest24.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbFdHI_2dqkVKsM_a7Ln3Bh0MCBuwmzm8',
    appId: '1:851697693723:ios:a204d557d71d14c0d234be',
    messagingSenderId: '851697693723',
    projectId: 'connexus-hackfest24',
    storageBucket: 'connexus-hackfest24.appspot.com',
    iosBundleId: 'com.example.connexus',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBbFdHI_2dqkVKsM_a7Ln3Bh0MCBuwmzm8',
    appId: '1:851697693723:ios:a204d557d71d14c0d234be',
    messagingSenderId: '851697693723',
    projectId: 'connexus-hackfest24',
    storageBucket: 'connexus-hackfest24.appspot.com',
    iosBundleId: 'com.example.connexus',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBhT0gC6t9TblT71RBBaQQa3CQ80DWtA-I',
    appId: '1:851697693723:web:a8c52ec396688016d234be',
    messagingSenderId: '851697693723',
    projectId: 'connexus-hackfest24',
    authDomain: 'connexus-hackfest24.firebaseapp.com',
    storageBucket: 'connexus-hackfest24.appspot.com',
  );
}
