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
    apiKey: 'AIzaSyDfyfjCqhgLHTZhRxEQ-ZdlBKdFT_ojDuk',
    appId: '1:507824000393:web:7fbab9ef16eaf52604e558',
    messagingSenderId: '507824000393',
    projectId: 'fitness-tracker-e30fe',
    authDomain: 'fitness-tracker-e30fe.firebaseapp.com',
    storageBucket: 'fitness-tracker-e30fe.firebasestorage.app',
    measurementId: 'G-F6MJG5XMYP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBcA_9O3bgf69B41QGyfYDYxq4OkJcOREs',
    appId: '1:507824000393:android:0ecfcb86ea65330104e558',
    messagingSenderId: '507824000393',
    projectId: 'fitness-tracker-e30fe',
    storageBucket: 'fitness-tracker-e30fe.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYzC2DgOHanu47xr2I_ktSvWVnzyd0MdY',
    appId: '1:507824000393:ios:966e0d4c4e812c3404e558',
    messagingSenderId: '507824000393',
    projectId: 'fitness-tracker-e30fe',
    storageBucket: 'fitness-tracker-e30fe.firebasestorage.app',
    iosBundleId: 'com.example.fitnessTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYzC2DgOHanu47xr2I_ktSvWVnzyd0MdY',
    appId: '1:507824000393:ios:966e0d4c4e812c3404e558',
    messagingSenderId: '507824000393',
    projectId: 'fitness-tracker-e30fe',
    storageBucket: 'fitness-tracker-e30fe.firebasestorage.app',
    iosBundleId: 'com.example.fitnessTracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfyfjCqhgLHTZhRxEQ-ZdlBKdFT_ojDuk',
    appId: '1:507824000393:web:1f5a9d743da4ee2904e558',
    messagingSenderId: '507824000393',
    projectId: 'fitness-tracker-e30fe',
    authDomain: 'fitness-tracker-e30fe.firebaseapp.com',
    storageBucket: 'fitness-tracker-e30fe.firebasestorage.app',
    measurementId: 'G-9LBWHDHMWG',
  );
}
