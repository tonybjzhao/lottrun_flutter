import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(NotificationService.instance.init());
  unawaited(PremiumService.instance.init());
  AnalyticsService.init(_initFirebase());
  await _initAds();
  runApp(const LottFunApp());
}

/// Initializes AdMob and registers test device IDs in debug builds
/// so banner ads fill during development.
Future<void> _initAds() async {
  if (Platform.isIOS) {
    // Disable same app key on iOS for the most conservative review posture.
    await MobileAds.instance.setSameAppKeyEnabled(false);
  }
  await MobileAds.instance.initialize();
  if (kDebugMode) {
    // Device ID from the log: "To get test ads on this device, set: ..."
    // Remove or leave empty before release — has no effect in release builds
    // since kDebugMode is false.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: ['c9807b9b342ebb9faedbeeb80e9905ed'],
      ),
    );
  }
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
