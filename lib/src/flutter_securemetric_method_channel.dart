import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_securemetric_platform_interface.dart';
import 'dart:developer' as dev;

/// An implementation of [FlutterSecuremetricPlatform] that uses method channels.
class MethodChannelFlutterSecuremetric extends FlutterSecuremetricPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.myKad/fingerprint');
  final String _tag = "Securemetric";

  @override
  Future<bool> callSDK({bool usingFP = false, String? license}) async {
    dev.log(name: _tag, "callSDK");
    try {
      String trialLicense =
          "eyJ2ZXJzaW9uIjoxLCJwYXlsb2FkIjoiNlVDaG5rVHZoZkt6b1FvZUVoWmIzUnEvaWVqak5ydUM5VmdmZ2VjdVFTejc5TXRtQ1VGS1pHZWJ2OXVmZnQ2MnJ3L1R4eWNVd0d1UTJVMXNwYW13WWxCSGQwVG9yS0I3dHE2UlVaQU5RMGo0d2NuMVhNSXBNaW1kNXc5WGlLWGtjU0FRT3RCdEZJMFdkek1KTm9xZlRKaVVNbjJlU3d0Yy9sUFdHYlY1cHN0UWhGM1l4bWxWZlRPWXQ1MWpZSE5NIiwic2lnbmF0dXJlIjoiTUVVQ0lRQ3R6UmRMc2tWcUdDYTBJVTdYdjBjNDIyRFV2U25rOXVwalk4QVorUi9kRWdJZ1IwSVRWOVVzV29yUTZOMGxOOHp3bTZ6anM2c2lwSXVnejBUL0kxdzdaSms9IiwiY2hhbGxhbmdlX2NvZGUiOiJuRGFsTFhsYzlLIn0=";
      if (license == null || license.isEmpty) {
        dev.log(name: _tag, " SDK: Using trial license ");
      }
      var args = {
        "usingFP": usingFP,
        "license": (license == null || license.isEmpty)
            ? trialLicense
            : license,
      };
      final isInitialize =
          await methodChannel.invokeMethod<bool>('myKadSDK', args) ?? false;
      dev.log(name: _tag, "SDK initialized: $isInitialize");
      return isInitialize;
    } on PlatformException catch (e) {
      dev.log(name: _tag, "Failed to call SDK: '${e.message}'.");
      return false;
    }
  }

  @override
  Future<void> connectFPScanner() async {
    dev.log(name: _tag, "connectFPScanner");
    try {
      final isDisconnected = await methodChannel.invokeMethod('connectScanner');
      dev.log(name: _tag, "Scanner connected: $isDisconnected");
    } on PlatformException catch (e) {
      dev.log(name: _tag, "Failed to connect: '${e.message}'.");
    }
  }

  @override
  Future<void> disconnectFPScanner() async {
    dev.log(name: _tag, "disconnectFPScanner");
    try {
      final isDisconnected = await methodChannel.invokeMethod(
        'disconnectScanner',
      );
      dev.log(name: _tag, "Scanner disconnected: $isDisconnected");
    } on PlatformException catch (e) {
      dev.log(name: _tag, "Scanner failed to disconnect: '${e.message}'.");
    }
  }

  @override
  Future<void> disposeSDK() async {
    dev.log(name: _tag, "disposeSDK");
    try {
      await methodChannel.invokeMethod('dispose');
    } on PlatformException catch (e) {
      dev.log("Failed to dispose: '${e.message}'.");
    }
  }

  @override
  Future<void> disposeListener() async {
    dev.log(name: _tag, "disposeSDK");
    try {
      await methodChannel.invokeMethod('dispose');
    } on PlatformException catch (e) {
      dev.log("Failed to dispose: '${e.message}'.");
    }
  }

  @override
  Future<String?> getFPDeviceList() async {
    dev.log(name: _tag, "getFPDeviceList");
    try {
      final data =
          await methodChannel.invokeMethod<String>('getFPDeviceList') ?? "-";
      dev.log(name: _tag, "Get device list: '$data.");
      return data;
    } on PlatformException catch (e) {
      dev.log(name: _tag, "Failed to get device list: '${e.message}'.");
      return null;
    }
  }

  @override
  Future<void> readFingerprint() async {
    dev.log(name: _tag, "readFingerprint");
    try {
      final val = await methodChannel.invokeMethod('readFingerprint');
      dev.log(name: _tag, "Read fingerprint :$val.");
    } on PlatformException catch (e) {
      dev.log(name: _tag, "Read fingerprint error: '${e.message}'.");
    }
  }

  @override
  Future<bool> turnOffFP() async {
    dev.log(name: _tag, "turnOffFP");
    try {
      final isDisconnected =
          await methodChannel.invokeMethod('turnOffFP') ?? false;
      dev.log(name: _tag, "FP turned off: $isDisconnected");
      return isDisconnected;
    } on PlatformException catch (e) {
      dev.log(name: _tag, "FP turned off error: '${e.message}'.");
      return false;
    }
  }

  @override
  Future<bool> turnOnFP() async {
    dev.log(name: _tag, "turnOnFP");
    try {
      final isConnected =
          await methodChannel.invokeMethod<bool>('turnOnFP') ?? false;
      dev.log(name: _tag, "FP turned on: $isConnected");
      return isConnected;
    } on PlatformException catch (e) {
      dev.log(name: _tag, "FP turned on error: '${e.message}'.");
      return false;
    }
  }
}
