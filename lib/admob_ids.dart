import 'dart:io';

class AdMobIds {
  static String get historyBanner {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9718685783142362/2914534027';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9718685783142362/8049096195';
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
