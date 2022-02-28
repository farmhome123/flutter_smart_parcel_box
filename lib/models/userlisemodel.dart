class UserList {
  final int userId;
  final String userName;
  final String userid;
  final String userTel;
  final String userEmail;
  final DateTime userCreatetime;
  final DateTime userUpdatetime;

  const UserList({
    required this.userId,
    required this.userName,
    required this.userid,
    required this.userTel,
    required this.userEmail,
    required this.userCreatetime,
    required this.userUpdatetime,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
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
