import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/firebase_config.dart';

class FirebaseService {
  FirebaseService._();

  static Future<FirebaseApp> initialize() => FirebaseConfig.initialize();

  static FirebaseAuth get auth {
    _requireInitialized();
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get firestore {
    _requireInitialized();
    return FirebaseFirestore.instance;
  }

  static FirebaseMessaging get messaging {
    _requireInitialized();
    return FirebaseMessaging.instance;
  }

  static bool get isSignedIn => FirebaseConfig.isInitialized && auth.currentUser != null;

  static void _requireInitialized() {
    if (!FirebaseConfig.isInitialized) {
      throw StateError('Firebase has not been initialized.');
    }
  }
}
