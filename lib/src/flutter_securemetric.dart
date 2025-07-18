// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_securemetric/src/model/sdk_response_model.dart';
import 'package:flutter_securemetric/src/securemetric_constants.dart';
import 'package:flutter_securemetric/src/securemetric_dialog.dart';
import 'flutter_securemetric_platform_interface.dart';
import 'dart:developer' as dev;

class FlutterSecuremetric {
  static const MethodChannel _channel = MethodChannel('com.myKad/fingerprint');
  final String _tag = "Securemetric";

  /// Calls native method to initialize SDK with optional license and fingerprint toggle
  Future<bool> callSDK({bool usingFP = false, String? license}) {
    return FlutterSecuremetricPlatform.instance.callSDK(
      usingFP: usingFP,
      license: license,
    );
  }

  /// Turns on fingerprint scanner
  Future<bool> turnOnFP() {
    return FlutterSecuremetricPlatform.instance.turnOnFP();
  }

  /// Turns off fingerprint scanner
  Future<void> turnOffFP() {
    return FlutterSecuremetricPlatform.instance.turnOffFP();
  }

  /// Connects fingerprint scanner
  Future<void> connectFPScanner() {
    return FlutterSecuremetricPlatform.instance.connectFPScanner();
  }

  /// Disconnects fingerprint scanner
  Future<void> disconnectFPScanner() {
    return FlutterSecuremetricPlatform.instance.disconnectFPScanner();
  }

  /// Requests to read fingerprint
  Future<void> readFingerprint() {
    return FlutterSecuremetricPlatform.instance.readFingerprint();
  }

  /// Gets fingerprint device list
  Future<String?> getFPDeviceList() {
    return FlutterSecuremetricPlatform.instance.getFPDeviceList();
  }

  /// Disposes the SDK
  Future<void> disposeSDK() {
    return FlutterSecuremetricPlatform.instance.disposeSDK();
  }

  /// Disposes the SDK
  Future<void> disposeListener() {
    return FlutterSecuremetricPlatform.instance.disposeListener();
  }

  /// Listen to SDK events from native side
  void sdkListener({
    bool isDebug = false,
    required BuildContext context,
    required void Function() onIdle,
    required void Function() onReadCard,
    required void Function(SdkResponseModel data) onSuccessCard,
    required void Function() onErrorCard,
    required void Function() onVerifyFP,
    required void Function() onSuccessFP,
    required void Function() onErrorFP,
  }) {
    _channel.setMethodCallHandler((call) async {
      final String data = call.arguments;
      final state = SecuremetricCardStatus.values.byName(call.method);

      if (state == SecuremetricCardStatus.READER_INSERTED) {
        onIdle();
      } else if (state == SecuremetricCardStatus.CARD_INSERTED) {
        onReadCard();
        dev.log(name: _tag, "CARD INSERTED");
        _showMessage(context, text: "CARD INSERTED");
      } else if (state == SecuremetricCardStatus.CARD_SUCCESS) {
        final sdkResponse = SdkResponseModel.fromJson(jsonDecode(data));
        onSuccessCard(sdkResponse);
        dev.log(name: _tag, "CARD SUCCESS");
        _showMessage(context, text: "CARD SUCCESS");
      } else if (state == SecuremetricCardStatus.CARD_INSERTED_ERROR) {
        // if (isDebug) debugErrorDialog(data, context);
        onErrorCard();
        dev.log(name: _tag, "CARD INSERTED ERROR $data");
        _showMessage(context, text: "CARD INSERTED ERROR $data");
      } else if (state == SecuremetricCardStatus.CARD_REMOVE) {
        onIdle();
        dev.log(name: _tag, "CARD REMOVE");
        _showMessage(context, text: "CARD REMOVE");
        // Fluttertoast.showToast(msg: "CARD REMOVE");
      } else if (state == SecuremetricCardStatus.VERIFY_FP) {
        onVerifyFP();
        dev.log(name: _tag, "VERIFY_FP $data");
        _showMessage(context, text: "VERIFY_FP $data");
        // Fluttertoast.showToast(msg: "VERIFY_FP $data");
      } else if (state == SecuremetricCardStatus.FP_FAILED_VERIFY ||
          state == SecuremetricCardStatus.FP_SCANNER_ERROR) {
        onErrorFP();
        dev.log(name: _tag, "FP FAILED VERIFY $data");
        _showMessage(context, text: "FP FAILED VERIFY $data");
        // Fluttertoast.showToast(msg: "FP FAILED VERIFY $data");
      } else if (state == SecuremetricCardStatus.FP_SUCCESS_VERIFY) {
        onSuccessFP();
        dev.log(name: _tag, "FP SUCCESS VERIFY $data");
        _showMessage(context, text: "FP SUCCESS VERIFY $data");
        // Fluttertoast.showToast(msg: "FP SUCCESS VERIFY $data");
      }
    });
  }

  void _showMessage(BuildContext context, {required String text}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void verify(
    BuildContext context, {
    required String? license,
    required SecuremetricDevice device,
    bool verifyFP = true,
    required Function(bool isVerifyFP) onVerifyFP,
    double initialChildSize = 0.6,
    double maxChildSize = 0.6,
    double minChildSize = 0.3,
  }) {
    SecuremetricDialog.show(
      context,
      license: license,
      device: device,
      onVerifyFP: onVerifyFP,
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      minChildSize: minChildSize,
    );
  }
}
