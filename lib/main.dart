import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Await Firebase — safe now that iOS deployment target is 15.0 (was 13.0).
  // The previous hang was caused by the dylib version mismatch, not the await.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  unawaited(MobileAds.instance.initialize());
  unawaited(FirebaseAnalytics.instance.logAppOpen());
  runApp(const LottFunApp());
}
