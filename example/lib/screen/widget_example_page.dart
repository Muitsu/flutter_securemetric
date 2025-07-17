// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_securemetric/securemetric_constants.dart';
import 'package:flutter_securemetric/securemetric_controller.dart';
import 'package:flutter_securemetric/securemetric_widget.dart';
import 'package:flutter_securemetric_example/widgets/blinking_text.dart';

class WidgetExamplePage extends StatefulWidget {
  final void Function(bool) onVerifyFP;
  const WidgetExamplePage({super.key, required this.onVerifyFP});

  @override
  State<WidgetExamplePage> createState() => _WidgetExamplePageState();
}

class _WidgetExamplePageState extends State<WidgetExamplePage>
    with WidgetsBindingObserver {
  final SecuremetricController sController = SecuremetricController();
  @override
  void initState() {
    super.initState();
    sController.init(
      license: null,
      verifyFP: true,
      context: context,
      device: SecuremetricDevice.v11,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      sController.close();
    }
  }

  @override
  void dispose() {
    sController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyKad Reader"),
        leading: BackButton(
          onPressed: () {
            showLoading(context);
            sController.close().then((val) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: Column(
              children: [
                SecuremetricWidget(
                  controller: sController,
                  onCardSuccess: (val) {},
                  onVerifyFP: (val) {
                    if (!val) return;
                    Future.delayed(const Duration(milliseconds: 800), () {
                      widget.onVerifyFP(val);
                      Navigator.pop(context);
                    });
                  },
                  builder: (context, msg) {
                    final readerStatus = ReaderStatus.queryStatus(msg);

                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: constraint.maxHeight * .12),
                          readerStatus.isLoading
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: constraint.maxHeight * .1,
                                  ),
                                  child: const CircularProgressIndicator(),
                                )
                              : FittedBox(child: readerStatus.widget),
                          SizedBox(height: constraint.maxHeight * .04),
                          readerStatus.isNotBlink
                              ? Text(
                                  readerStatus.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : BlinkingText(
                                  readerStatus.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          Visibility(
                            visible: readerStatus.showTryAgain,
                            child: ElevatedButton(
                              onPressed: sController.tryAgain,
                              child: const Text("Try Again"),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                  child: const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
