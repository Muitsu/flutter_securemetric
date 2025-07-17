import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:flutter_securemetric/flutter_securemetric.dart';
import 'package:flutter_securemetric/model/my_kad_model.dart';
import 'package:flutter_securemetric/model/my_kid_model.dart';
import 'package:flutter_securemetric/model/sdk_response_model.dart';

class FunctionExamplePage extends StatefulWidget {
  const FunctionExamplePage({super.key});

  @override
  State<FunctionExamplePage> createState() => _FunctionExamplePageState();
}

class _FunctionExamplePageState extends State<FunctionExamplePage> {
  Future addDelay({int milisec = 1500}) =>
      Future.delayed(Duration(milliseconds: milisec));
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }

  bool isInitialize = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MyKad Debugger")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _button(
              onPressed: () async {
                if (isInitialize) {
                  showSnackBar(context, "Please dispose");
                  return;
                }
                await FlutterSecuremetric().callSDK();
                setState(() => isInitialize = true);
                /* --- Start M11 settings ---*/
                if (!context.mounted) return;
                await initFP(context);
                /* --- End M11 settings   ---*/

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
                    setMessage(msg: "Read card successful");
                    // if (verifyFP) {
                    //   await MyKadReader.turnOnFP();
                    //   await addDelay(milisec: 2500);
                    //   setMessage(msg: "Initialize Fingerprint Hardware...");
                    //   await MyKadReader.getFPDeviceList();
                    //   await addDelay(milisec: 2000);
                    //   await connectAndScanFP();
                    // }
                  },
                  onErrorCard: () {
                    //Remove card and try again
                    setMessage(msg: "Remove card and try again");
                  },
                  onVerifyFP: () {
                    //Verifying Fingerprint
                    setMessage(
                      msg: "Please place your fingerprint at the scanner",
                    );
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
              },
              title: "Initiate SDK",
            ),
            _button(
              onPressed: () async {
                if (!isInitialize) {
                  showSnackBar(context, "Please Initialize");
                  return;
                }
                await FlutterSecuremetric().disconnectFPScanner();
                await addDelay();
                await FlutterSecuremetric().turnOffFP();
                await addDelay();
                await FlutterSecuremetric().disposeListener();
                setState(() => isInitialize = false);
              },
              title: "Dispose SDK",
            ),
            _button(
              onPressed: () {
                close();
              },
              title: "Restart SDK",
            ),
          ],
        ),
      ),
    );
  }

  Padding _button({
    required void Function()? onPressed,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(onPressed: onPressed, child: Text(title)),
    );
  }

  Future initFP(BuildContext context) async {
    showLoading(context);
    setMessage(msg: "Initialize Fingerprint Hardware...");
    await FlutterSecuremetric().turnOnFP();
    await addDelay(milisec: 2500);
    await FlutterSecuremetric().disconnectFPScanner();
    await addDelay();
    await FlutterSecuremetric().connectFPScanner();
    if (!context.mounted) return;
    closeLoading(context);
  }

  void setMessage({required String msg}) {
    dev.log(msg);
    showSnackBar(context, msg);
  }

  void setMyKadData(SdkResponseModel? data) {
    if (data == null) {
      return;
    }
    final json = jsonDecode(data.data!);
    String icNO = "";
    if (data.isDataMykad()) {
      icNO = MyKadModel.fromJson(json).icNo ?? "";
    } else {
      icNO = MyKidModel.fromJson(json).icNo ?? "";
    }
    setMessage(msg: icNO);
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 100,
                  width: 100,
                  padding: const EdgeInsets.all(15),
                  color: Colors.white,
                  child: const CircularProgressIndicator(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Close the StreamController
  Future<void> close() async {
    setMyKadData(null);
    await FlutterSecuremetric().disconnectFPScanner();
    await addDelay();
    await FlutterSecuremetric().turnOffFP();
    await addDelay();
    await FlutterSecuremetric().disposeListener();
  }
}
