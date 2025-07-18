import 'package:flutter/material.dart';

class CustomLoading {
  final BuildContext context;
  final Key? key;
  CustomLoading({required this.context, this.key});
  factory CustomLoading.of(BuildContext context, {Key? key}) {
    return CustomLoading(context: context, key: key);
  }
  Future<dynamic> showLoading() async {
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

  void closeLoading() => Navigator.pop(context);
}
