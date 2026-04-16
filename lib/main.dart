import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Start Firebase in the background — never block runApp() on iOS.
  // AnalyticsService.init() stores the future and awaits it internally
  // before every log call, so no event ever fires before Firebase is ready.
  final firebaseInit = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AnalyticsService.init(firebaseInit);
  unawaited(MobileAds.instance.initialize());
  runApp(const LottFunApp());
}
