import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform yet.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-pJfFVndCqQENAsYHNjd9-kLVwz-wXsw',
    appId: '1:1066615778167:web:eb326011ac316be1a18f72',
    messagingSenderId: '1066615778167',
    projectId: 'farm-to-home-8c520',
    authDomain: 'farm-to-home-8c520.firebaseapp.com',
    storageBucket: 'farm-to-home-8c520.firebasestorage.app',
    measurementId: 'G-H9GD71QDLP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApSbb_ZR2UU96x1pCHPCY8g8gvCY-c7wk',
    appId: '1:1066615778167:android:96acfdf9e4f57b76a18f72',
    messagingSenderId: '1066615778167',
    projectId: 'farm-to-home-8c520',
    storageBucket: 'farm-to-home-8c520.firebasestorage.app',
  );
}
