import 'package:flutter/material.dart';
import 'package:flutter_securemetric/flutter_securemetric.dart';
import 'dart:developer' as dev;

class SecuremetricHelper {
  final String _tag = "SecuremetricHelper";
  final bool isDebug;
  const SecuremetricHelper({required this.isDebug});

  /// Initialize SDK
  void initializeSDK({
    required BuildContext context,
    required String? license,
    required SecuremetricDevice device,
    required void Function(bool isInitialize) onInitialize,
    required void Function() onIdle,
    required void Function() onReadCard,
    required void Function(SdkResponseModel data) onSuccessCard,
    required void Function() onErrorCard,
    required void Function() onVerifyFP,
    required void Function() onSuccessFP,
    required void Function() onErrorFP,
  }) async {
    _showLoading(context);
    _setMessage(context, msg: "Connecting to : ${device.name} SDK");
    final isSuccess = await FlutterSecuremetric().callSDK();
    if (!isSuccess) {
      if (!context.mounted) return;
      onInitialize(false);
      _closeLoading(context);
      _setMessage(context, msg: "Fail to reached SDK");
      return;
    }

    if (device == SecuremetricDevice.v11) {
      if (!context.mounted) return;
      await _initializeV11SDK(context);
    }
    if (!context.mounted) return;
    onInitialize(true);
    _closeLoading(context);
    FlutterSecuremetric().sdkListener(
      context: context,
      onIdle: () {
        //Please insert card
        _setMessage(context, msg: "Please insert card");
        onIdle();
      },
      onReadCard: () {
        //Loading ...
        _setMessage(context, msg: "Loading read card...");
        onReadCard();
      },
      onSuccessCard: (data) async {
        //Success read card
        _setMessage(context, msg: "Read card successful");
        onSuccessCard(data);
      },
      onErrorCard: () {
        //Remove card and try again
        _setMessage(context, msg: "Remove card and try again");
        onErrorCard();
      },
      onVerifyFP: () {
        //Verifying Fingerprint
        _setMessage(
          context,
          msg: "Please place your fingerprint at the scanner",
        );
        onVerifyFP();
      },
      onSuccessFP: () {
        //Success verify fingerprint
        _setMessage(context, msg: "User verification successful");
        onSuccessFP();
      },
      onErrorFP: () async {
        //Please try again
        _setMessage(context, msg: "Error: Please try again");
        onErrorFP();
      },
    );
  }

  /// Initialize v11 Device
  Future<void> _initializeV11SDK(BuildContext context) async {
    _setMessage(context, msg: "Initialize V11 Hardware ...");
    await FlutterSecuremetric().turnOnFP();
    await _addDelay(milisec: 2500);
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
  }

  ///Verify Fingerprint
  Future<void> verifyFP(BuildContext context) async {
    await FlutterSecuremetric().turnOnFP();
    await _addDelay(milisec: 2500);
    if (!context.mounted) return;
    _setMessage(context, msg: "Initialize Fingerprint Hardware...");
    await FlutterSecuremetric().getFPDeviceList();
    await _addDelay(milisec: 2000);
    await _connectAndScanFP();
  }

  /// Retry Fingerprint
  Future retryVerifyFP(BuildContext context) async {
    _setMessage(context, msg: "Re Initialize Fingerprint Hardware...");
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().readFingerprint();
  }

  /// Connect and Start Scanning Fingerprint
  Future _connectAndScanFP() async {
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().readFingerprint();
  }

  /// Restart SDK to reconnect
  Future restartSDK() async {
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().turnOffFP();
    await _addDelay();
    await FlutterSecuremetric().disposeListener();
  }

  /// Debug message
  void _setMessage(BuildContext context, {required String msg}) {
    dev.log(name: _tag, msg);
    if (isDebug) {
      _showSnackBar(context, msg);
    }
  }

  /// Secure delay
  Future _addDelay({int milisec = 1500}) =>
      Future.delayed(Duration(milliseconds: milisec));

  void _showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    // Hide any current SnackBar
    messenger.hideCurrentSnackBar();

    // Show the new SnackBar
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }

  /// Dispose SDK
  Future<void> dispose() async {
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().turnOffFP();
    await _addDelay();
    await FlutterSecuremetric().disposeSDK();
  }

  Future<dynamic> _showLoading(BuildContext context) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {},
        child: GestureDetector(
          onTap: () {},
          child: Material(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    "Please wait...",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _closeLoading(BuildContext context) => Navigator.pop(context);
}
