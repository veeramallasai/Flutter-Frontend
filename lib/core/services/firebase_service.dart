import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../config/firebase_config.dart';

class FirebaseService {
  FirebaseService._();

  static Future<FirebaseApp> initialize() => FirebaseConfig.initialize();

  static BackendAuth get auth {
    _requireInitialized();
    return BackendAuth.instance;
  }

  static FirebaseFirestore get firestore {
    _requireInitialized();
    return FirebaseFirestore.instance;
  }

  static bool get isSignedIn =>
      FirebaseConfig.isInitialized && auth.currentUser != null;

  static void _requireInitialized() {
    if (!FirebaseConfig.isInitialized) {
      throw StateError('Firebase has not been initialized.');
    }
  }
}
