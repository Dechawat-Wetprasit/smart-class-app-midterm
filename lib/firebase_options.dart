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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCj-t_TU-Qmfkae7Tmz6ifs1UAzZhGRW8g',
    appId: '1:983194575699:web:5c941af257c86c7085b7a6',
    messagingSenderId: '983194575699',
    projectId: 'smart-class-app-5eaab',
    authDomain: 'smart-class-app-5eaab.firebaseapp.com',
    storageBucket: 'smart-class-app-5eaab.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCj-t_TU-Qmfkae7Tmz6ifs1UAzZhGRW8g',
    appId: '1:983194575699:web:5c941af257c86c7085b7a6',
    messagingSenderId: '983194575699',
    projectId: 'smart-class-app-5eaab',
    storageBucket: 'smart-class-app-5eaab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCj-t_TU-Qmfkae7Tmz6ifs1UAzZhGRW8g',
    appId: '1:983194575699:web:5c941af257c86c7085b7a6',
    messagingSenderId: '983194575699',
    projectId: 'smart-class-app-5eaab',
    storageBucket: 'smart-class-app-5eaab.firebasestorage.app',
  );
}
