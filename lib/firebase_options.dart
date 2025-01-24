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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDYJT6UW2T3yQ-Pg3uy5p1jNkfmOYysYqc',
    appId: '1:781667469773:web:fa399ca7b54111e6061c84',
    messagingSenderId: '781667469773',
    projectId: 'mycards-c7f33',
    authDomain: 'mycards-c7f33.firebaseapp.com',
    storageBucket: 'mycards-c7f33.firebasestorage.app',
    measurementId: 'G-ZN8MEEXR2V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlvdR1cTd2_-_-yZ9_plcALTbkirNPiaU',
    appId: '1:781667469773:android:1100ad3fdcb471de061c84',
    messagingSenderId: '781667469773',
    projectId: 'mycards-c7f33',
    storageBucket: 'mycards-c7f33.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtyWxHr96O_QUcqSyGQw9CNJfwIIJoinY',
    appId: '1:781667469773:ios:cd90e289f857c331061c84',
    messagingSenderId: '781667469773',
    projectId: 'mycards-c7f33',
    storageBucket: 'mycards-c7f33.firebasestorage.app',
    iosBundleId: 'com.example.mycards',
  );
}
