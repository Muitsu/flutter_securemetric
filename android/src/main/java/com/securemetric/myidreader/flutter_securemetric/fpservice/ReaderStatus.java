package com.securemetric.myidreader.flutter_securemetric.fpservice;

public enum ReaderStatus {
    READER_INSERTED,
    CARD_INSERTED,
    CARD_INSERTED_ERROR,
    CARD_REMOVE,
    READER_REMOVED,
    CARD_SUCCESS,
    FP_FAILED_VERIFY,
    FP_SCANNER_ERROR,
    FP_SUCCESS_VERIFY;
}
