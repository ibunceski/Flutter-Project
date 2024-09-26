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
    apiKey: 'AIzaSyBQK-hIbQfY8Pol1DqcTSMYh0DL2uW1ho4',
    appId: '1:354009555938:web:ed82cc71f235b5c1568fbb',
    messagingSenderId: '354009555938',
    projectId: 'flutterlearning-notes-project',
    authDomain: 'flutterlearning-notes-project.firebaseapp.com',
    storageBucket: 'flutterlearning-notes-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCKG7iH80thdqLsZgYxmapStKXwCxGlF9I',
    appId: '1:354009555938:android:4120d4b4d373b18c568fbb',
    messagingSenderId: '354009555938',
    projectId: 'flutterlearning-notes-project',
    storageBucket: 'flutterlearning-notes-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxsRb56kjgVnjp5puOSDBZNaD1DaSPdt0',
    appId: '1:354009555938:ios:c7251daa3d79f732568fbb',
    messagingSenderId: '354009555938',
    projectId: 'flutterlearning-notes-project',
    storageBucket: 'flutterlearning-notes-project.appspot.com',
    iosBundleId: 'com.ibunc.notesapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjd3qHODHo_QrtuSZLyY9E4AlGM1InFt8',
    appId: '1:322245472354:ios:1e44a3afe9a90d12bee13b',
    messagingSenderId: '322245472354',
    projectId: 'flutterlearning-notesapp',
    storageBucket: 'flutterlearning-notesapp.appspot.com',
    iosBundleId: 'com.ibunc.notesapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBQK-hIbQfY8Pol1DqcTSMYh0DL2uW1ho4',
    appId: '1:354009555938:web:9f56013f2f5d0696568fbb',
    messagingSenderId: '354009555938',
    projectId: 'flutterlearning-notes-project',
    authDomain: 'flutterlearning-notes-project.firebaseapp.com',
    storageBucket: 'flutterlearning-notes-project.appspot.com',
  );

}