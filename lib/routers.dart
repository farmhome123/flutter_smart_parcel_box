import 'package:flutter/material.dart';
import 'package:smartparcelbox/screens/home/home.dart';
import 'package:smartparcelbox/screens/login/login.dart';

final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  "/login": (BuildContext context) => LoginScreen(),
  // "/home": (BuildContext context) => HomeScreen(cameras: widget.cameras),
};
