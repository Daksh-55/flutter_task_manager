import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
    apiKey: 'AIzaSyCyTey1CAI5X9jlNzcpec6SO6o2ZgxIijs',
    appId: '1:289239007734:web:f7ad2a3184067ba68207d7',
    messagingSenderId: '289239007734',
    projectId: 'task-manager-ffc9d',
    storageBucket: 'task-manager-ffc9d.firebasestorage.app',
    authDomain: 'task-manager-ffc9d.firebaseapp.com',
    measurementId: 'G-Y4NFJ4KZ9T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyTey1CAI5X9jlNzcpec6SO6o2ZgxIijs',
    appId: '1:289239007734:android:cab2b91172387aed8207d7',
    messagingSenderId: '289239007734',
    projectId: 'task-manager-ffc9d',
    storageBucket: 'task-manager-ffc9d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyTey1CAI5X9jlNzcpec6SO6o2ZgxIijs',
    appId: '1:289239007734:ios:964215be911d994e8207d7',
    messagingSenderId: '289239007734',
    projectId: 'task-manager-ffc9d',
    storageBucket: 'task-manager-ffc9d.firebasestorage.app',
    iosBundleId: 'com.example.flutterTaskManager',
  );
}