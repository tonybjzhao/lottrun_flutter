import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web is not supported.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions not configured for ${defaultTargetPlatform.name}');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5ix00sBgpdGXUN3q_F5Qo4qXbQnm3FRQ',
    appId: '1:252612268699:android:43e677f6aef668bd122c3e',
    messagingSenderId: '252612268699',
    projectId: 'lottfun',
    storageBucket: 'lottfun.firebasestorage.app',
  );

  // TODO: replace with real iOS values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '252612268699',
    projectId: 'lottfun',
    storageBucket: 'lottfun.firebasestorage.app',
    iosBundleId: 'com.in5km.lottfun',
  );
}
