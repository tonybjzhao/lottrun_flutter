import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(NotificationService.instance.init());
  AnalyticsService.init(_initFirebase());
  if (Platform.isIOS) await _requestTrackingPermission();
  await _initAds();
  runApp(const LottFunApp());
}

Future<void> _requestTrackingPermission() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}

/// Initializes AdMob and registers test device IDs in debug builds
/// so banner ads fill during development.
Future<void> _initAds() async {
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
