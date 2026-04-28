import 'dart:io' show Platform;

class PlatformText {
  static bool get _ios => Platform.isIOS;

  static String t(String android, String ios) => _ios ? ios : android;
}
