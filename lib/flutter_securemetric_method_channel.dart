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
  // @override
  // Future<String?> getPlatformVersion() async {
  //   final version = await methodChannel.invokeMethod<String>(
  //     'getPlatformVersion',
  //   );
  //   return version;
  // }

  @override
  Future<void> callSDK({bool usingFP = false, String? license}) async {
    dev.log(name: _tag, "callSDK");
  }

  @override
  Future<void> connectFPScanner() async {
    dev.log(name: _tag, "connectFPScanner");
  }

  @override
  Future<void> disconnectFPScanner() async {
    dev.log(name: _tag, "disconnectFPScanner");
  }

  @override
  Future<void> disposeSDK() async {
    dev.log(name: _tag, "disposeSDK");
  }

  @override
  Future<void> disposeListener() async {
    dev.log(name: _tag, "disposeSDK");
  }

  @override
  Future<String?> getFPDeviceList() async {
    dev.log(name: _tag, "getFPDeviceList");
    return null;
  }

  @override
  Future<void> readFingerprint() async {
    dev.log(name: _tag, "readFingerprint");
  }

  @override
  Future<void> turnOffFP() async {
    dev.log(name: _tag, "turnOffFP");
  }

  @override
  Future<void> turnOnFP() async {
    dev.log(name: _tag, "turnOnFP");
  }
}
