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
    apiKey: 'AIzaSyCPiukh7LfvvDu57yLLSCnchFPiwje5qUQ',
    appId: '1:564011799817:web:d86bc2394c52c2429d6fd8',
    messagingSenderId: '564011799817',
    projectId: 'blog-bb1f1',
    authDomain: 'blog-bb1f1.firebaseapp.com',
    storageBucket: 'blog-bb1f1.appspot.com',
    measurementId: 'G-F30EMC4PXT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC9zXbyrKWyR-wuxO9B7t4QwD75Igl-cps',
    appId: '1:564011799817:android:cb8f0e89f430c17d9d6fd8',
    messagingSenderId: '564011799817',
    projectId: 'blog-bb1f1',
    storageBucket: 'blog-bb1f1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmv9Gl78CtVc4XoFBpJasioU3P4By6gyQ',
    appId: '1:564011799817:ios:280b19319ee215109d6fd8',
    messagingSenderId: '564011799817',
    projectId: 'blog-bb1f1',
    storageBucket: 'blog-bb1f1.appspot.com',
    iosBundleId: 'com.example.blog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBmv9Gl78CtVc4XoFBpJasioU3P4By6gyQ',
    appId: '1:564011799817:ios:280b19319ee215109d6fd8',
    messagingSenderId: '564011799817',
    projectId: 'blog-bb1f1',
    storageBucket: 'blog-bb1f1.appspot.com',
    iosBundleId: 'com.example.blog',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPiukh7LfvvDu57yLLSCnchFPiwje5qUQ',
    appId: '1:564011799817:web:191abfb58b659aa29d6fd8',
    messagingSenderId: '564011799817',
    projectId: 'blog-bb1f1',
    authDomain: 'blog-bb1f1.firebaseapp.com',
    storageBucket: 'blog-bb1f1.appspot.com',
    measurementId: 'G-5VN2CY929E',
  );
}
