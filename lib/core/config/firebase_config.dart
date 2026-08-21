import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseConfig {
  FirebaseConfig._();

  static bool get isInitialized => Firebase.apps.isNotEmpty;
  static FirebaseApp? get app => isInitialized ? Firebase.app() : null;
  static String get projectId => DefaultFirebaseOptions.currentPlatform.projectId;

  static Future<FirebaseApp> initialize() async {
    if (isInitialized) return Firebase.app();
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
