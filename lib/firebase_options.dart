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
    apiKey: 'AIzaSyAz3bfLLwB3Hk9tHzqL5BBtmjDlHMvaxCc',
    appId: '1:112965137189:web:95a1b2deba4e39e3f6e0cc',
    messagingSenderId: '112965137189',
    projectId: 'dartgpt-b0795',
    authDomain: 'dartgpt-b0795.firebaseapp.com',
    storageBucket: 'dartgpt-b0795.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkON4v9FQZYN7HtovDLn6CEe67--sgdU0',
    appId: '1:112965137189:android:23a6729e3db9a75df6e0cc',
    messagingSenderId: '112965137189',
    projectId: 'dartgpt-b0795',
    storageBucket: 'dartgpt-b0795.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtLFpLSg1HOCw7Oc4Q4144tpILsDpPkSk',
    appId: '1:112965137189:ios:ee2d29b49e73a8f1f6e0cc',
    messagingSenderId: '112965137189',
    projectId: 'dartgpt-b0795',
    storageBucket: 'dartgpt-b0795.firebasestorage.app',
    iosBundleId: 'com.example.dartgpt',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtLFpLSg1HOCw7Oc4Q4144tpILsDpPkSk',
    appId: '1:112965137189:ios:ee2d29b49e73a8f1f6e0cc',
    messagingSenderId: '112965137189',
    projectId: 'dartgpt-b0795',
    storageBucket: 'dartgpt-b0795.firebasestorage.app',
    iosBundleId: 'com.example.dartgpt',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAz3bfLLwB3Hk9tHzqL5BBtmjDlHMvaxCc',
    appId: '1:112965137189:web:4651780db98f21d4f6e0cc',
    messagingSenderId: '112965137189',
    projectId: 'dartgpt-b0795',
    authDomain: 'dartgpt-b0795.firebaseapp.com',
    storageBucket: 'dartgpt-b0795.firebasestorage.app',
  );
}
