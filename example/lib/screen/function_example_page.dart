import 'package:flutter/material.dart';

import 'package:flutter_securemetric/flutter_securemetric.dart';
import 'package:flutter_securemetric_example/widgets/custom_loading.dart';
import 'dart:developer' as dev;

class FunctionExamplePage extends StatefulWidget {
  const FunctionExamplePage({super.key});

  @override
  State<FunctionExamplePage> createState() => _FunctionExamplePageState();
}

class _FunctionExamplePageState extends State<FunctionExamplePage> {
  SecuremetricHelper sHelper = SecuremetricHelper(isDebug: true);

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
                sHelper.initializeSDK(
                  context: context,
                  license: null,
                  device: SecuremetricDevice.v11,
                  onInitialize: (init) {
                    setState(() => isInitialize = init);
                  },
                  onIdle: () {
                    //Do somthing ...
                  },
                  onReadCard: () {
                    //Do somthing ...
                  },
                  onSuccessCard: (sdkResponse) {
                    // Retrieve My Kad / My Kid data
                    if (sdkResponse.isDataMykad()) {
                      sdkResponse.getMyKadModel();
                    } else {
                      sdkResponse.getMyKidModel();
                    }
                    // Can continue to fingerprint after success read card
                    // sHelper.verifyFP(context);
                  },
                  onErrorCard: () {
                    //Do somthing ...
                  },
                  onVerifyFP: () {
                    //Do somthing ...
                  },
                  onSuccessFP: () {
                    //Do somthing ...
                  },
                  onErrorFP: () {
                    //Do somthing ...
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
                await sHelper.dispose();
                setState(() => isInitialize = false);
              },
              title: "Dispose SDK",
            ),
            _button(
              onPressed: () {
                sHelper.restartSDK();
              },
              title: "Restart SDK",
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({required void Function()? onPressed, required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(onPressed: onPressed, child: Text(title)),
    );
  }

  Future<dynamic> showLoading(BuildContext context) =>
      CustomLoading.of(context).showLoading();

  void closeLoading(BuildContext context) =>
      CustomLoading.of(context).closeLoading();

  void setMessage({required String msg}) {
    dev.log(msg);
    showSnackBar(context, msg);
  }

  void showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }
}
