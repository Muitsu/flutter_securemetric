import 'dart:async';

import 'package:flutter/material.dart';

import 'securemetric_controller.dart';

class SecuremetricWidget extends StatefulWidget {
  final SecuremetricController controller;
  final Widget Function(BuildContext context, String msg)? builder;
  final void Function(String msg)? onListen;
  final void Function(bool val) onCardSuccess;
  final void Function(bool val) onVerifyFP;
  const SecuremetricWidget({
    super.key,
    required this.controller,
    this.builder,
    required this.onCardSuccess,
    required this.onVerifyFP,
    this.onListen,
  });

  @override
  State<SecuremetricWidget> createState() => _SecuremetricWidgetState();
}

class _SecuremetricWidgetState extends State<SecuremetricWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.controller.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Waiting for connection...');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final msg = snapshot.data?.message ?? "";
          setListener(msg);
          setFunction(msg);
          return widget.builder != null
              ? widget.builder!(context, msg)
              : const SizedBox();
        } else {
          return const Text('No device found');
        }
      },
    );
  }

  void setListener(String msg) {
    if (widget.onListen != null) {
      widget.onListen!(msg);
    }
  }

  void setFunction(String msg) {
    final lowerMsg = msg.toLowerCase();
    if (lowerMsg.contains("remove card") || lowerMsg.contains("insert card")) {
      widget.onCardSuccess(false);
      widget.onVerifyFP(false);
    } else if (lowerMsg.contains("read card successful")) {
      widget.onCardSuccess(true);
    }

    if (lowerMsg.contains("verification successful")) {
      widget.onVerifyFP(true);
    } else if (lowerMsg.contains("try again")) {
      widget.onVerifyFP(false);
    }
  }
}

class ScmBlinkText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final TextAlign? textAlign;
  const ScmBlinkText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.textAlign,
  });

  @override
  ScmBlinkTextState createState() => ScmBlinkTextState();
}

class ScmBlinkTextState extends State<ScmBlinkText> {
  bool _isVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {
        _isVisible = !_isVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: widget.duration,
      child: Text(
        widget.text,
        textAlign: widget.textAlign,
        style: widget.style,
      ),
    );
  }
}
