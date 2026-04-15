import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget — do not await; avoids blocking app startup on iOS.
  MobileAds.instance.initialize();
  runApp(const LottFunApp());
}
