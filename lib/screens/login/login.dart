import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smartparcelbox/models/usermodel.dart';
import 'package:smartparcelbox/screens/home/home.dart';
import 'package:smartparcelbox/service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // String _group_token = "301704aba8b3510e";
  // String _group_password = "H25cMKtJSmek";
   String _group_token = "";
  String _group_password = "";
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _tokenFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late UserModel _usermodel;
  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    print(_group_token);
    print(_group_password);
    final prefs = await SharedPreferences.getInstance();
    print('Login');
    print('Token: ${_group_token}');
    print('Password: ${_group_password}');
    var data = {"group_token": _group_token, "group_password": _group_password};
    var url = Uri.parse(connect().url + "api/user/login/group");
    var response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      _usermodel = userModelFromJson(response.body);
      print(_usermodel);
      print('status : ${_usermodel.data.status}');
      if (_usermodel.data.status == true) {
        if (_usermodel.data.message[0].groupId != null) {
          await prefs.setString(
              'group_id', _usermodel.data.message[0].groupId.toString());
          await prefs.setString(
              'group_name', _usermodel.data.message[0].groupName.toString());
          await prefs.setString('group_location',
              _usermodel.data.message[0].groupLocation.toString());
          await prefs.setString('group_detail',
              _usermodel.data.message[0].groupDetail.toString());
          await prefs.setString(
              'group_token', _usermodel.data.message[0].groupToken.toString());
          await prefs.setString('group_password',
              _usermodel.data.message[0].groupPassword.toString());
          await prefs.setString('group_ads',
              _usermodel.data.message[0].groupAds.toString());
          await prefs.setString('group_createtime',
              _usermodel.data.message[0].groupCreatetime.toString());
          await prefs.setString('group_updatetime',
              _usermodel.data.message[0].groupUpdatetime.toString());
          Fluttertoast.showToast(
              msg: "เช้าสู่ระบบเรียบร้อยแล้ว",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>  HomeScreen(),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(
            msg: "เข้าสู่ระบบไม่สำเร็จกรุณาตรวจสอบ usernameและpassword",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: size.height * 0.08),
                  Container(
                    child: Image.asset(
                      "assets/images/SOSSLOGO.png",
                      width: size.width * 0.45,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'ลงชื่อเข้าใช้',
                    style: TextStyle(fontSize: 30, color: Colors.black54),
                  ),
                  SizedBox(height: size.height * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        focusNode: _tokenFocusNode,
                        onSaved: (value) {
                          _group_token = value!;
                        },
                        initialValue: _group_token,
                        key: ValueKey("username"),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            labelText: "Username",
                            prefixIcon: Icon(Icons.person)),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 4) {
                            return "Username must be at least 4 character!";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.025),
                      TextFormField(
                        key: ValueKey("password"),
                        initialValue: _group_password,
                        focusNode: _passwordFocusNode,
                        onSaved: (value) {
                          _group_password = value!;
                        },
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0))),
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) {
                            return "Password must be at least 6 character!";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.05),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green[100]!,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset:
                              Offset(0, 8.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    width: double.infinity,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: EdgeInsets.all(17),
                      color: Colors.green[300],
                      textColor: Colors.white,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
