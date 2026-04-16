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
  // Guard against duplicate-app on hot reload: native Firebase persists
  // across Dart restarts, so only call initializeApp() if not yet done.
  final firebaseInit = Firebase.apps.isNotEmpty
      ? Future.value(Firebase.app())
      : Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AnalyticsService.init(firebaseInit);
  unawaited(MobileAds.instance.initialize());
  runApp(const LottFunApp());
  // Temp: confirm Firebase actually finished initializing.
  firebaseInit.then((_) => dev.log('🔥 Firebase initialized OK'))
              .catchError((e) => dev.log('🔥 Firebase init FAILED: $e'));
}
