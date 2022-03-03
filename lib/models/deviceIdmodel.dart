// To parse this JSON data, do
//
//     final deviceIdModel = deviceIdModelFromJson(jsonString);

import 'dart:convert';

DeviceIdModel deviceIdModelFromJson(String str) =>
    DeviceIdModel.fromJson(json.decode(str));

String deviceIdModelToJson(DeviceIdModel data) => json.encode(data.toJson());

class DeviceIdModel {
  DeviceIdModel({
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

  factory DeviceIdModel.fromJson(Map<String, dynamic> json) => DeviceIdModel(
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
    required this.deviceId,
    required this.deviceName,
    required this.deviceStatus,
    required this.deviceCreatetime,
    required this.deviceUpdatetime,
    required this.groupId,
    required this.logId,
    required this.deviceSuccess,
    required this.userId,
    required this.devicePassword,
  });

  int deviceId;
  String deviceName;
  int deviceStatus;
  DateTime deviceCreatetime;
  DateTime deviceUpdatetime;
  int groupId;
  int logId;
  int deviceSuccess;
  int userId;
  String devicePassword;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        deviceId: json["device_id"],
        deviceName: json["device_name"],
        deviceStatus: json["device_status"],
        deviceCreatetime: DateTime.parse(json["device_createtime"]),
        deviceUpdatetime: DateTime.parse(json["device_updatetime"]),
        groupId: json["group_id"],
        logId: json["log_id"],
        deviceSuccess: json["device_success"],
        userId: json["user_id"],
        devicePassword: json["device_password"],
      );

  Map<String, dynamic> toJson() => {
        "device_id": deviceId,
        "device_name": deviceName,
        "device_status": deviceStatus,
        "device_createtime": deviceCreatetime.toIso8601String(),
        "device_updatetime": deviceUpdatetime.toIso8601String(),
        "group_id": groupId,
        "log_id": logId,
        "device_success": deviceSuccess,
        "user_id": userId,
        "device_password": devicePassword,
      };
}
