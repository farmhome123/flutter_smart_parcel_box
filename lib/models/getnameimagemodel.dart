import 'dart:convert';

GetNameModel getNameModelFromJson(String str) =>
    GetNameModel.fromJson(json.decode(str));

String getNameModelToJson(GetNameModel data) => json.encode(data.toJson());

class GetNameModel {
  GetNameModel({
    required this.store,
    required this.timestamp,
    required this.serverstatus,
    required this.page,
    required this.data,
  });

  final String store;
  final String timestamp;
  final bool serverstatus;
  final String page;
  final Data data;

  factory GetNameModel.fromJson(Map<String, dynamic> json) => GetNameModel(
        store: json["store"],
        timestamp: json["timestamp"],
        serverstatus: json["serverstatus"],
        page: json["page"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "store": store,
        "timestamp": timestamp,
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
    required this.img,
  });

  final bool err;
  final bool status;
  final Message message;
  final String img;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        err: json["err"],
        status: json["status"],
        message: Message.fromJson(json["message"]),
        img: json["img"],
      );

  Map<String, dynamic> toJson() => {
        "err": err,
        "status": status,
        "message": message.toJson(),
        "img": img,
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
  });

  final int fieldCount;
  final int affectedRows;
  final int insertId;
  final int serverStatus;
  final int warningCount;
  final String message;
  final bool protocol41;
  final int changedRows;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        fieldCount: json["fieldCount"],
        affectedRows: json["affectedRows"],
        insertId: json["insertId"],
        serverStatus: json["serverStatus"],
        warningCount: json["warningCount"],
        message: json["message"],
        protocol41: json["protocol41"],
        changedRows: json["changedRows"],
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
      };
}
