import 'dart:async';
import 'dart:developer' as dev;

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

/// Initializes Firebase exactly once across all launch scenarios:
/// - fresh install, hot restart, and cases where AppDelegate or another
///   plugin has already initialized the native layer.
Future<FirebaseApp> _initFirebase() async {
  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Native Firebase already running (hot restart, or prior init).
      dev.log('🔥 Firebase already initialized — reusing existing app');
      return Firebase.app();
    }
    dev.log('🔥 Firebase init FAILED: $e');
    rethrow;
  }
}
