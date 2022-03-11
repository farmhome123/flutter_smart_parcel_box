import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparcelbox/routers.dart';
import 'package:smartparcelbox/screens/home/home.dart';
import 'package:smartparcelbox/screens/login/login.dart';
import 'package:wakelock/wakelock.dart';

var initURL;
var group_id;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  group_id = prefs.getString('group_id');
  if (group_id != null) {
    initURL = '/home';
  } else {
    initURL = '/login';
  }
  runApp(MyApp(
    cameras: cameras,
  ));
}

class MyApp extends StatelessWidget {
  List<CameraDescription>? cameras;
  MyApp({Key? key, required this.cameras}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: initURL,
      // routes: routes,
      home: group_id != null ? HomeScreen() : LoginScreen(),
    );
  }
}
