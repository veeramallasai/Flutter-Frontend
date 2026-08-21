import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }
}