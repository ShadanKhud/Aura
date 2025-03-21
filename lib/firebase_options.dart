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
    apiKey: 'AIzaSyDy9Bh58IhUG3znJ192Eq96hq8AeRke8Pw',
    appId: '1:33195017380:web:95ce1a2bc187b3caf01231',
    messagingSenderId: '33195017380',
    projectId: 'aura-9e354',
    authDomain: 'aura-9e354.firebaseapp.com',
    storageBucket: 'aura-9e354.firebasestorage.app',
    measurementId: 'G-N1KVSJ4DRE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVg0kAwWiX1JdN9kSnLKWt0YA47s75kWc',
    appId: '1:33195017380:android:5ba70075254e0a58f01231',
    messagingSenderId: '33195017380',
    projectId: 'aura-9e354',
    storageBucket: 'aura-9e354.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuG4cJs7tg8ac1BmtstiBZOK0eCg96dww',
    appId: '1:33195017380:ios:e4a3ac1bf8280b40f01231',
    messagingSenderId: '33195017380',
    projectId: 'aura-9e354',
    storageBucket: 'aura-9e354.firebasestorage.app',
    iosBundleId: 'com.example.auraApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAuG4cJs7tg8ac1BmtstiBZOK0eCg96dww',
    appId: '1:33195017380:ios:e4a3ac1bf8280b40f01231',
    messagingSenderId: '33195017380',
    projectId: 'aura-9e354',
    storageBucket: 'aura-9e354.firebasestorage.app',
    iosBundleId: 'com.example.auraApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDy9Bh58IhUG3znJ192Eq96hq8AeRke8Pw',
    appId: '1:33195017380:web:ffe7e58555f68e51f01231',
    messagingSenderId: '33195017380',
    projectId: 'aura-9e354',
    authDomain: 'aura-9e354.firebaseapp.com',
    storageBucket: 'aura-9e354.firebasestorage.app',
    measurementId: 'G-LC2G7LFYR5',
  );
}
