import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_securemetric/src/flutter_securemetric_platform_interface.dart';
import 'package:flutter_securemetric/src/flutter_securemetric_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:developer' as dev;

class MockFlutterSecuremetricPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSecuremetricPlatform {
  final String _tag = "MockFlutterSecuremetricPlatform";

  @override
  Future<bool> callSDK({bool usingFP = false, String? license}) async {
    dev.log(name: _tag, "callSDK");
    return true;
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
  Future<String?> getFPDeviceList() async {
    dev.log(name: _tag, "getFPDeviceList");
    return null;
  }

  @override
  Future<void> readFingerprint() async {
    dev.log(name: _tag, "readFingerprint");
  }

  @override
  Future<bool> turnOffFP() async {
    dev.log(name: _tag, "turnOffFP");
    return true;
  }

  @override
  Future<bool> turnOnFP() async {
    dev.log(name: _tag, "turnOnFP");
    return true;
  }

  @override
  Future<void> disposeListener() async {
    dev.log(name: _tag, "disposeListener");
  }
}

void main() {
  final FlutterSecuremetricPlatform initialPlatform =
      FlutterSecuremetricPlatform.instance;

  test('$MethodChannelFlutterSecuremetric is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSecuremetric>());
  });

  test('getPlatformVersion', () async {
    // FlutterSecuremetric flutterSecuremetricPlugin = FlutterSecuremetric();
    MockFlutterSecuremetricPlatform fakePlatform =
        MockFlutterSecuremetricPlatform();
    FlutterSecuremetricPlatform.instance = fakePlatform;

    // expect(await flutterSecuremetricPlugin.getPlatformVersion(), '42');
  });
}
