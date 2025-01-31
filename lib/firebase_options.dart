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
    apiKey: 'AIzaSyDTUzZryUnhv9usjWSPnkzn_AZSPxpYmz4',
    appId: '1:128155516744:web:b12a2b24ad8cf098793d7d',
    messagingSenderId: '128155516744',
    projectId: 'tiempos-79cc3',
    authDomain: 'tiempos-79cc3.firebaseapp.com',
    storageBucket: 'tiempos-79cc3.appspot.com',
    measurementId: 'G-L4V0NECZ4P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5UFFkaMIxMV5eWVpQe1DXpca6PgpUeEg',
    appId: '1:128155516744:android:b095b3889b86cd7b793d7d',
    messagingSenderId: '128155516744',
    projectId: 'tiempos-79cc3',
    storageBucket: 'tiempos-79cc3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANDoq6E6-xFIAXX-ZqZCjQ8GzGN9ebKtw',
    appId: '1:128155516744:ios:1f4ed7aab524d046793d7d',
    messagingSenderId: '128155516744',
    projectId: 'tiempos-79cc3',
    storageBucket: 'tiempos-79cc3.appspot.com',
    iosClientId: '128155516744-ich0paraid72dp0l1efnc9bon8kh69n6.apps.googleusercontent.com',
    iosBundleId: 'com.example.tiemposApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyANDoq6E6-xFIAXX-ZqZCjQ8GzGN9ebKtw',
    appId: '1:128155516744:ios:1f4ed7aab524d046793d7d',
    messagingSenderId: '128155516744',
    projectId: 'tiempos-79cc3',
    storageBucket: 'tiempos-79cc3.appspot.com',
    iosClientId: '128155516744-ich0paraid72dp0l1efnc9bon8kh69n6.apps.googleusercontent.com',
    iosBundleId: 'com.example.tiemposApp',
  );
}
