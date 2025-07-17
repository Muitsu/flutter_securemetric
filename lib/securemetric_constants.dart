// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum SecuremetricDevice { v11, v20 }

enum SecuremetricCardStatus {
  READER_INSERTED,
  CARD_INSERTED,
  CARD_SUCCESS,
  CARD_INSERTED_ERROR,
  CARD_REMOVE,
  READER_REMOVED,
  VERIFY_FP,
  FP_FAILED_VERIFY,
  FP_SCANNER_ERROR,
  FP_SUCCESS_VERIFY,
}

enum ReaderStatus {
  insert(
    title: "Please insert card",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.upload), Text("Please insert card")],
    ),
    query: "insert card",
  ),
  cardSuccess(
    title: "Read card successful",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.check_circle), Text("Read card successful")],
    ),
    query: "card successful",
  ),
  cardFailed(
    title: "Remove card and try again",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.warning), Text("Remove card and try again")],
    ),
    query: "and try again",
  ),
  remove(
    title: "Remove card",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.close), Text("Remove card and try again")],
    ),
    query: "remove card",
  ),
  insertFP(
    title: "Please place your fingerprint at the scanner",
    widget: Icon(Icons.fingerprint),
    query: "place your fingerprint",
  ),
  successFP(
    title: "User verification successful",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.person), Text("User verification successful")],
    ),
    query: "verification successful",
  ),
  failedFP(
    title: "Error: Please try again",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(Icons.error), Text("Error: Please try again")],
    ),
    query: "error: please",
  ),
  loading(
    title: "Loading ...",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [CircularProgressIndicator(), Text("Loading ...")],
    ),
    query: "loading",
  ),
  loadingFP(
    title: "Initialize Fingerprint Hardware...",
    widget: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        Text("Initialize Fingerprint Hardware..."),
      ],
    ),
    query: "initialize fingerprint",
  );

  final String title;
  final Widget widget;
  final String query;

  bool get isLoading =>
      this == ReaderStatus.loading || this == ReaderStatus.loadingFP;

  bool get isNotBlink =>
      this == ReaderStatus.cardSuccess || this == ReaderStatus.successFP;

  bool get showTryAgain => this == ReaderStatus.failedFP;

  static ReaderStatus queryStatus(String query) {
    final result = ReaderStatus.values
        .where((stat) => query.toLowerCase().contains(stat.query.toLowerCase()))
        .toList();
    return result.isNotEmpty ? result.first : ReaderStatus.loading;
  }

  const ReaderStatus({
    required this.title,
    required this.widget,
    required this.query,
  });
}
