// To parse this JSON data, do
//
//     final imageNameModel = imageNameModelFromJson(jsonString);

import 'dart:convert';

ImageNameModel imageNameModelFromJson(String str) =>
    ImageNameModel.fromJson(json.decode(str));

String imageNameModelToJson(ImageNameModel data) => json.encode(data.toJson());

class ImageNameModel {
  ImageNameModel({
    required this.store,
    required this.timestamp,
    required this.serverstatus,
    required this.page,
    required this.data,
  });

  String store;
  DateTime timestamp;
  bool serverstatus;
  String page;
  Data data;

  factory ImageNameModel.fromJson(Map<String, dynamic> json) => ImageNameModel(
        store: json["store"],
        timestamp: DateTime.parse(json["timestamp"]),
        serverstatus: json["serverstatus"],
        page: json["page"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "store": store,
        "timestamp": timestamp.toIso8601String(),
        "serverstatus": serverstatus,
        "page": page,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    required this.err,
    required this.status,
    required this.message,
  });

  bool err;
  bool status;
  Message message;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        err: json["err"],
        status: json["status"],
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "err": err,
        "status": status,
        "message": message.toJson(),
      };
}

class Message {
  Message({
    required this.fieldCount,
    required this.affectedRows,
    required this.insertId,
    required this.serverStatus,
    required this.warningCount,
    required this.message,
    required this.protocol41,
    required this.changedRows,
    required this.file,
  });

  int fieldCount;
  int affectedRows;
  int insertId;
  int serverStatus;
  int warningCount;
  String message;
  bool protocol41;
  int changedRows;
  String file;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        fieldCount: json["fieldCount"],
        affectedRows: json["affectedRows"],
        insertId: json["insertId"],
        serverStatus: json["serverStatus"],
        warningCount: json["warningCount"],
        message: json["message"],
        protocol41: json["protocol41"],
        changedRows: json["changedRows"],
        file: json["file"],
      );

  Map<String, dynamic> toJson() => {
        "fieldCount": fieldCount,
        "affectedRows": affectedRows,
        "insertId": insertId,
        "serverStatus": serverStatus,
        "warningCount": warningCount,
        "message": message,
        "protocol41": protocol41,
        "changedRows": changedRows,
        "file": file,
      };
}
