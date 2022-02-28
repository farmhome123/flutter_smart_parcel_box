// To parse this JSON data, do
//
//     final userAllModel = userAllModelFromJson(jsonString);

import 'dart:convert';

UserAllModel userAllModelFromJson(String str) => UserAllModel.fromJson(json.decode(str));

String userAllModelToJson(UserAllModel data) => json.encode(data.toJson());

class UserAllModel {
    UserAllModel({
       required this.store,
       required this.timestamp,
      required  this.serverstatus,
      required  this.page,
      required  this.data,
    });

    String store;
    DateTime timestamp;
    bool serverstatus;
    String page;
    Data data;

    factory UserAllModel.fromJson(Map<String, dynamic> json) => UserAllModel(
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
      required  this.err,
    required    this.status,
    required    this.message,
    });

    bool err;
    bool status;
    List<Message> message;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        err: json["err"],
        status: json["status"],
        message: List<Message>.from(json["message"].map((x) => Message.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "err": err,
        "status": status,
        "message": List<dynamic>.from(message.map((x) => x.toJson())),
    };
}

class Message {
    Message({
    required    this.userId,
    required    this.userName,
    required    this.userid,
    required    this.userTel,
    required    this.userEmail,
     required   this.userCreatetime,
     required   this.userUpdatetime,
    });

    int userId;
    String userName;
    String userid;
    String userTel;
    String userEmail;
    DateTime userCreatetime;
    DateTime userUpdatetime;

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        userId: json["user_id"],
        userName: json["user_name"],
        userid: json["userid"],
        userTel: json["user_tel"],
        userEmail: json["user_email"],
        userCreatetime: DateTime.parse(json["user_createtime"]),
        userUpdatetime: DateTime.parse(json["user_updatetime"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_name": userName,
        "userid": userid,
        "user_tel": userTel,
        "user_email": userEmail,
        "user_createtime": userCreatetime.toIso8601String(),
        "user_updatetime": userUpdatetime.toIso8601String(),
    };
}
