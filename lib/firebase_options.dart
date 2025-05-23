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
    apiKey: 'AIzaSyATZcLgJYSaO0o-HQQrJHAbhg2ynGyoiyM',
    appId: '1:608051181552:web:c73ded622fbfb6cf984f35',
    messagingSenderId: '608051181552',
    projectId: 'zapato-4faa6',
    authDomain: 'zapato-4faa6.firebaseapp.com',
    storageBucket: 'zapato-4faa6.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAn7g0US_BMsrp9v6hjEfakPMmfKiyt0e8',
    appId: '1:608051181552:android:d671d7fc7349d205984f35',
    messagingSenderId: '608051181552',
    projectId: 'zapato-4faa6',
    storageBucket: 'zapato-4faa6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMHGY9IwOU5CpEJ-cSVz91fOHU18BdSoI',
    appId: '1:608051181552:ios:b689b7f489b6642e984f35',
    messagingSenderId: '608051181552',
    projectId: 'zapato-4faa6',
    storageBucket: 'zapato-4faa6.firebasestorage.app',
    iosBundleId: 'com.example.zapato',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMHGY9IwOU5CpEJ-cSVz91fOHU18BdSoI',
    appId: '1:608051181552:ios:b689b7f489b6642e984f35',
    messagingSenderId: '608051181552',
    projectId: 'zapato-4faa6',
    storageBucket: 'zapato-4faa6.firebasestorage.app',
    iosBundleId: 'com.example.zapato',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATZcLgJYSaO0o-HQQrJHAbhg2ynGyoiyM',
    appId: '1:608051181552:web:c504a54383cc7edc984f35',
    messagingSenderId: '608051181552',
    projectId: 'zapato-4faa6',
    authDomain: 'zapato-4faa6.firebaseapp.com',
    storageBucket: 'zapato-4faa6.firebasestorage.app',
  );

}