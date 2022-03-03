import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparcelbox/screens/login/login.dart';

class WidgetDrawer extends StatelessWidget {
  const WidgetDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String? _password;
    // H25cMKtJSmek
    final _textpassword = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _validate = true;

    _showPasswordDialog(context) async {
      final prefs = await SharedPreferences.getInstance();
      Alert(
          context: context,
          title: "กรุณากรอกรหัสผ่าน",
          content: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    labelText: "Password", icon: Icon(Icons.lock)),
                maxLines: 1,
                initialValue: 'H25cMKtJSmek',
                onChanged: (value) => _password = value,
                validator: (value) =>
                    value!.trim().isEmpty ? 'กรุณากรอก Password' : null,
              ),
            ],
          ),
          buttons: [
            DialogButton(
              color: Colors.green[200],
              onPressed: () async {
                var g_password = await prefs.get('group_password');
                if (_password != null) {
                  if (_password.toString() == g_password.toString()) {
                    print('logout');
                    prefs.remove('group_id');
                    prefs.remove('group_name');
                    prefs.remove('group_location');
                    prefs.remove('group_detail');
                    prefs.remove('group_token');
                    prefs.remove('group_password');
                    prefs.remove('group_ads');
                    prefs.remove('group_createtime');
                    prefs.remove('group_updatetime');
                    Fluttertoast.showToast(
                        msg: "ออกจากระบบเรียบร้อยแล้ว",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen(),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: "รหัสผ่านไม่ถูกต้อง",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                } else {
                  Fluttertoast.showToast(
                      msg: "กรุณากรอกรหัสผ่าน",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: Text(
                "ตกลง",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    }

    return Drawer(
      key: _formKey,
      child: ListView(
        children: [
          DrawerHeader(
            child: Container(
              child: Image.asset(
                "assets/images/SOSSLOGO.png",
                width: size.width * 0.40,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              _showPasswordDialog(context);
            },
            leading: Icon(
              Icons.logout,
              color: Colors.green[200],
            ),
            title: Text(
              'Log out',
              style: TextStyle(color: Colors.green[200]),
            ),
          ),
        ],
      ),
    );
  }
}
