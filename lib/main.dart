import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AnalyticsService.init(_initFirebase());
  unawaited(MobileAds.instance.initialize());
  runApp(const LottFunApp());
}

/// Initializes Firebase exactly once.
/// AppDelegate.configure() runs first (native/synchronous from plist),
/// so Dart's initializeApp() will always see duplicate-app and we return
/// the already-running app. The try-catch also covers hot-restart re-entry.
Future<FirebaseApp> _initFirebase() async {
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // ignore: avoid_print
      print('🔥 Firebase: reusing native app (duplicate-app caught)');
      return Firebase.app();
    }
    // ignore: avoid_print
    print('🔥 Firebase init FAILED: $e');
    rethrow;
  }
}
