import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_securemetric/src/flutter_securemetric.dart';
import 'package:flutter_securemetric/src/securemetric_constants.dart';
import 'model/model.dart';

class SecuremetricController {
  // Private constructor
  SecuremetricController._privateConstructor();

  // Singleton instance
  static final SecuremetricController _instance =
      SecuremetricController._privateConstructor();

  // Factory constructor to return the singleton instance
  factory SecuremetricController() {
    return _instance;
  }

  StreamController<ReaderResponse>? controller;
  MyKadModel? _myKadModel;
  MyKidModel? _myKidModel;
  SdkResponseModel? _sdkResponseModel;

  // Get the stream
  Stream<ReaderResponse>? get stream => controller?.stream;
  SdkResponseModel? get getSdkResponseModel => _sdkResponseModel;
  MyKadModel? get getMyKad => _myKadModel;
  MyKidModel? get getMyKid => _myKidModel;

  /// Initialize the StreamController & FlutterSecuremetric()
  void init({
    required BuildContext context,
    required String? license,
    required SecuremetricDevice device,
    bool verifyFP = true,
  }) async {
    if (controller == null) {
      controller = StreamController<ReaderResponse>.broadcast();
      final isSuccess = await FlutterSecuremetric().callSDK(
        usingFP: verifyFP,
        license: license,
      );
      if (!isSuccess) return;
      /* --- Start V11 settings ---*/
      if (device == SecuremetricDevice.v11) {
        if (!context.mounted) return;
        await initFP(context);
      }
      /* --- End V11 settings   ---*/

      if (!context.mounted) return;
      FlutterSecuremetric().sdkListener(
        context: context,
        onIdle: () {
          //Please insert card
          setMessage(msg: "Please insert card");
        },
        onReadCard: () {
          //Loading ...
          setMyKadData(null);
          setMessage(msg: "Loading read card...");
        },
        onSuccessCard: (data) async {
          setMyKadData(data);
          //Success read card
          setMessage(msg: "Read card successful", data: data);
          if (verifyFP) {
            await FlutterSecuremetric().turnOnFP();
            await _addDelay(milisec: 2500);
            setMessage(msg: "Initialize Fingerprint Hardware...");
            await FlutterSecuremetric().getFPDeviceList();
            await _addDelay(milisec: 2000);
            await connectAndScanFP();
          }
        },
        onErrorCard: () {
          //Remove card and try again
          setMessage(msg: "Remove card and try again");
        },
        onVerifyFP: () {
          //Verifying Fingerprint
          setMessage(msg: "Please place your fingerprint at the scanner");
        },
        onSuccessFP: () {
          //Success verify fingerprint
          setMessage(msg: "User verification successful");
        },
        onErrorFP: () async {
          //Please try again
          setMessage(msg: "Error: Please try again");
        },
      );
    }
  }

  Future _addDelay({int milisec = 1500}) =>
      Future.delayed(Duration(milliseconds: milisec));

  void _addData(ReaderResponse data) => controller?.sink.add(data);

  Future connectAndScanFP() async {
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().readFingerprint();
  }

  Future initFP(BuildContext context) async {
    showLoading(context);
    setMessage(msg: "Initialize Fingerprint Hardware...");
    await FlutterSecuremetric().turnOnFP();
    await _addDelay(milisec: 2500);
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
    if (!context.mounted) return;
    closeLoading(context);
  }

  Future tryAgain() async {
    setMessage(msg: "Initialize Fingerprint Hardware...");
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().connectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().readFingerprint();
  }

  void setMessage({SdkResponseModel? data, required String msg}) {
    var resp = ReaderResponse(
      data: data?.toJson().toString() ?? "",
      message: msg,
    );
    _addData(resp);
  }

  void setMyKadData(SdkResponseModel? data) {
    _sdkResponseModel = data;
    if (data == null) {
      _myKadModel = null;
      _myKidModel = null;
      return;
    }
    if (data.isDataMykad()) {
      _myKadModel = data.getMyKadModel();
    } else {
      _myKidModel = data.getMyKidModel();
    }
  }

  // Close the StreamController
  Future<void> close() async {
    controller?.close();
    controller = null;
    setMyKadData(null);
    await FlutterSecuremetric().disconnectFPScanner();
    await _addDelay();
    await FlutterSecuremetric().turnOffFP();
    await _addDelay();
    await FlutterSecuremetric().disposeSDK();
  }

  void closeLoading(BuildContext context) => Navigator.pop(context);

  Future<dynamic> showLoading(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
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
}
