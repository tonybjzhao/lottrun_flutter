import 'dart:io' show Platform;

/// Feature flag for showing banner ad on History page.
const bool kShowHistoryBannerAd = true;

/// True when running on an iOS Simulator or Android Emulator.
/// Uses env-var detection (dart:io only) — no extra package needed.
bool get kIsSimulatorOrEmulator {
  if (Platform.isIOS) {
    // SIMULATOR_DEVICE_NAME is always set inside Xcode simulators.
    return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }
  if (Platform.isAndroid) {
    // ro.kernel.qemu=1 on AOSP emulators; check via brand/product is fragile,
    // but the env var below is reliable for standard Android Studio AVDs.
    return Platform.environment.containsKey('ANDROID_EMULATOR_HOME');
  }
  return false;
}
