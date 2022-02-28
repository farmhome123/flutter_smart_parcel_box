import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparcelbox/routers.dart';
import 'package:smartparcelbox/screens/login/login.dart';
import 'package:wakelock/wakelock.dart';

var initURL;
var group_id;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  group_id = prefs.getString('group_id');
  if (group_id != null) {
    initURL = '/home';
  } else {
    initURL = '/login';
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: initURL,
      routes: routes,
    );
  }
}
