import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_securemetric/flutter_securemetric.dart';
import 'package:flutter_securemetric/flutter_securemetric_platform_interface.dart';
import 'package:flutter_securemetric/flutter_securemetric_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterSecuremetricPlatform
    with MockPlatformInterfaceMixin
    implements FlutterSecuremetricPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterSecuremetricPlatform initialPlatform = FlutterSecuremetricPlatform.instance;

  test('$MethodChannelFlutterSecuremetric is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterSecuremetric>());
  });

  test('getPlatformVersion', () async {
    FlutterSecuremetric flutterSecuremetricPlugin = FlutterSecuremetric();
    MockFlutterSecuremetricPlatform fakePlatform = MockFlutterSecuremetricPlatform();
    FlutterSecuremetricPlatform.instance = fakePlatform;

    expect(await flutterSecuremetricPlugin.getPlatformVersion(), '42');
  });
}
