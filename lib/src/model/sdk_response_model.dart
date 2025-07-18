import 'dart:convert';
import 'model.dart';

class SdkResponseModel {
  String? status;
  String? message;
  String? data;
  SdkResponseModel({this.status, this.message, this.data});

  factory SdkResponseModel.fromJson(Map<String, dynamic> json) {
    return SdkResponseModel(
      status: json["status"],
      message: json["message"],
      data: json["data"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"status": status, "message": message, "data": data};
  }

  bool isDataMykad() {
    return message!.toLowerCase().contains("mykad");
  }

  MyKadModel? getMyKadModel() {
    final json = jsonDecode(data!);
    if (isDataMykad()) {
      return MyKadModel.fromJson(json);
    }
    return null;
  }

  MyKidModel? getMyKidModel() {
    final json = jsonDecode(data!);
    if (!isDataMykad()) {
      return MyKidModel.fromJson(json);
    }
    return null;
  }
}
