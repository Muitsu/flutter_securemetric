import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_securemetric_method_channel.dart';

abstract class FlutterSecuremetricPlatform extends PlatformInterface {
  /// Constructs a FlutterSecuremetricPlatform.
  FlutterSecuremetricPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSecuremetricPlatform _instance =
      MethodChannelFlutterSecuremetric();

  /// The default instance of [FlutterSecuremetricPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSecuremetric].
  static FlutterSecuremetricPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSecuremetricPlatform] when
  /// they register themselves.
  static set instance(FlutterSecuremetricPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Future<String?> getPlatformVersion() {
  //   throw UnimplementedError('platformVersion() has not been implemented.');
  // }

  //
  Future<void> callSDK({bool usingFP = false, String? license});
  Future<void> turnOnFP();
  Future<void> turnOffFP();
  Future<void> connectFPScanner();
  Future<void> disconnectFPScanner();
  Future<void> readFingerprint();
  Future<String?> getFPDeviceList();
  Future<void> disposeSDK();
}
