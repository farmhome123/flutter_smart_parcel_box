// To parse this JSON data, do
//
//     final modelUrlad = modelUrladFromJson(jsonString);

import 'dart:convert';

ModelUrlad modelUrladFromJson(String str) =>
    ModelUrlad.fromJson(json.decode(str));

String modelUrladToJson(ModelUrlad data) => json.encode(data.toJson());

class ModelUrlad {
  ModelUrlad({
    required this.store,
    required this.timestamp,
    required this.serverstatus,
    required this.page,
    required this.data,
  });

  String store;
  String timestamp;
  bool serverstatus;
  String page;
  Data data;

  factory ModelUrlad.fromJson(Map<String, dynamic> json) => ModelUrlad(
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
  });

  bool err;
  bool status;
  List<Message> message;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        err: json["err"],
        status: json["status"],
        message:
            List<Message>.from(json["message"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "err": err,
        "status": status,
        "message": List<dynamic>.from(message.map((x) => x.toJson())),
      };
}

class Message {
  Message({
    required this.groupId,
    required this.groupName,
    required this.groupLocation,
    required this.groupDetail,
    required this.groupToken,
    required this.groupPassword,
    required this.groupAds,
    required this.groupCreatetime,
    required this.groupUpdatetime,
  });

  int groupId;
  String groupName;
  String groupLocation;
  String groupDetail;
  String groupToken;
  String groupPassword;
  String groupAds;
  DateTime groupCreatetime;
  DateTime groupUpdatetime;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        groupId: json["group_id"],
        groupName: json["group_name"],
        groupLocation: json["group_location"],
        groupDetail: json["group_detail"],
        groupToken: json["group_token"],
        groupPassword: json["group_password"],
        groupAds: json["group_ads"],
        groupCreatetime: DateTime.parse(json["group_createtime"]),
        groupUpdatetime: DateTime.parse(json["group_updatetime"]),
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "group_name": groupName,
        "group_location": groupLocation,
        "group_detail": groupDetail,
        "group_token": groupToken,
        "group_password": groupPassword,
        "group_ads": groupAds,
        "group_createtime": groupCreatetime.toIso8601String(),
        "group_updatetime": groupUpdatetime.toIso8601String(),
      };
}
