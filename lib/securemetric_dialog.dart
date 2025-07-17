import 'package:flutter/material.dart';
import 'package:flutter_securemetric/securemetric_constants.dart';
import 'package:flutter_securemetric/securemetric_controller.dart';
import 'package:flutter_securemetric/securemetric_widget.dart';

class SecuremetricDialog extends StatefulWidget {
  final String? license;
  final SecuremetricDevice device;
  final void Function(bool isVerifyFP) onVerifyFP;
  final bool verifyFP;
  final double initialChildSize;
  final double maxChildSize;
  final double minChildSize;
  const SecuremetricDialog({
    super.key,
    required this.device,
    required this.license,
    this.verifyFP = true,
    required this.onVerifyFP,
    this.initialChildSize = 0.6,
    this.maxChildSize = 0.6,
    this.minChildSize = 0.3,
  });

  @override
  State<SecuremetricDialog> createState() => _SecuremetricDialogState();

  static Future show(
    BuildContext context, {
    required String? license,
    required SecuremetricDevice device,
    bool verifyFP = true,
    required Function(bool isVerifyFP) onVerifyFP,
    double initialChildSize = 0.6,
    double maxChildSize = 0.6,
    double minChildSize = 0.3,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          child: SecuremetricDialog(
            verifyFP: verifyFP,
            onVerifyFP: onVerifyFP,
            device: device,
            license: license,
            initialChildSize: initialChildSize,
            maxChildSize: maxChildSize,
            minChildSize: minChildSize,
          ),
        );
      },
    );
  }
}

class _SecuremetricDialogState extends State<SecuremetricDialog>
    with WidgetsBindingObserver {
  final SecuremetricController sController = SecuremetricController();
  @override
  void initState() {
    super.initState();
    sController.init(
      context: context,
      verifyFP: widget.verifyFP,
      license: widget.license,
      device: widget.device,
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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (context, sc) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            extendBodyBehindAppBar: true,
            body: LayoutBuilder(
              builder: (context, constraint) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SecuremetricWidget(
                        controller: sController,
                        onCardSuccess: (val) {},
                        onVerifyFP: (val) {
                          if (!val) return;
                          Future.delayed(const Duration(milliseconds: 800), () {
                            widget.onVerifyFP(val);
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          });
                        },
                        builder: (context, msg) {
                          final readerStatus = ReaderStatus.queryStatus(msg);
                          // final readerStatus = ReaderStatus.insert;

                          return Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: constraint.maxHeight * .12),
                                readerStatus.isNotBlink
                                    ? Text(
                                        readerStatus.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : Text(
                                        readerStatus.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                SizedBox(height: constraint.maxHeight * .18),
                                readerStatus.isLoading
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                          top: constraint.maxHeight * .1,
                                        ),
                                        child:
                                            const CircularProgressIndicator(),
                                      )
                                    : FittedBox(child: readerStatus.widget),
                                SizedBox(height: constraint.maxHeight * .04),
                                Visibility(
                                  visible: readerStatus.showTryAgain,
                                  child: ElevatedButton(
                                    onPressed: sController.tryAgain,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      child: Text("Try Again"),
                                    ),
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
          ),
        );
      },
    );
  }
}
