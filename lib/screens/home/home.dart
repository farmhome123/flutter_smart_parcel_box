import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparcelbox/components/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:smartparcelbox/models/deviceIdmodel.dart';
import 'package:smartparcelbox/models/devicemodel.dart';
import 'package:smartparcelbox/screens/locker/depositlocker.dart';
import 'package:smartparcelbox/screens/locker/locker.dart';
import 'package:smartparcelbox/service.dart';
import 'package:wakelock/wakelock.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DeviceModel? _deviceModel;
  DeviceModel? _deviceModel_new;
  late Timer timer;
  DeviceIdModel? _deviceIdModel;
  final box = GetStorage();

  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (_) {
      // timedOut();
      print('TimeOut');
      // TimeOut();
      Wakelock.enable();
    });
  }

  void getDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var _group_id = prefs.get('group_id');
      print('group_id ==> ${_group_id}');

      var url =
          Uri.parse(connect().url + "api/device/group/group_id/${_group_id}");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _deviceModel = deviceModelFromJson(response.body);
        });
        print(_deviceModel);
      }
    } catch (e) {
      print(e);
    }
  }

  void getDeviceNew() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var _group_id = prefs.get('group_id');
      // print('group_id ==> ${_group_id}');

      var url =
          Uri.parse(connect().url + "api/device/group/group_id/${_group_id}");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // print('getDeviceNew == 200');
        setState(() {
          _deviceModel_new = deviceModelFromJson(response.body);
          if(jsonEncode(_deviceModel_new!.data.message) != jsonEncode(_deviceModel!.data.message)){
            _deviceModel = _deviceModel_new;
          }
        });
      
      }
    } catch (e) {
      print(e);
    }
  }

  void TimeOut() async {
    timer.cancel();
    late String videoId;
    videoId = YoutubePlayer.convertUrlToId(
        "https://www.youtube.com/watch?v=VgOzPNQ4-Qw&list=RDMMVqbbrekbL3s&index=3")!;
    print(videoId);
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    print('TimeOut');
    showDialog(
        context: context,
        builder: (_) {
          return Container(
            child: Dialog(
              child: Container(
                height: MediaQuery.of(context).size.height / 0.5,
                width: MediaQuery.of(context).size.width / 0.5,
                child: YoutubePlayer(
                  controller: _controller,
                ),
              ),
            ),
          );
        });
  }

  void readDeviceId(deviceId) async {
    try {
      print("Function ---> readDeviceId");
      print('ID device ===> $deviceId');
      var url =
          Uri.parse(connect().url + "api/device/group/device_id/${deviceId}");
      print(url);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _deviceIdModel = deviceIdModelFromJson(response.body);
        });
        print(_deviceIdModel);
      }
      print(jsonEncode(_deviceIdModel));
      if (_deviceIdModel!.data.message.devicePassword != null) {
        _showPasswordDialog(context);
      }
    } catch (e) {
      print(e);
    }
  }

  _showDepositDialog(context, lockname, group_id, device_id) async {
    Alert(
        context: context,
        content: Text('ต้องการฝากของช่อง $lockname '),
        buttons: [
          DialogButton(
              child: Text(
                'ตกลง',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              onPressed: () {
                box.write('group_id', group_id);
                box.write('device_id', device_id);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DepositlockerScreen()));
              })
        ]).show();
  }

  _showPasswordDialog(context) async {
    String? _password;
    String? passwordDevice = _deviceIdModel!.data.message.devicePassword;
    String? _logID = _deviceIdModel!.data.message.logId.toString();
    String? _deviceID = _deviceIdModel!.data.message.deviceId.toString();
    print('passwordDevice ===> $passwordDevice');
    print('logID ==> $_logID');
    Alert(
        context: context,
        title: "กรุณากรอกรหัสผ่าน",
        content: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  labelText: "Password", icon: Icon(Icons.lock)),
              maxLines: 1,
              onChanged: (value) => _password = value,
              validator: (value) =>
                  value!.trim().isEmpty ? 'กรุณากรอก Password' : null,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.green[200],
            onPressed: () {
              if (_password != null) {
                if (_password.toString() == passwordDevice.toString()) {
                  print('รหัสผ่านถูกต้อง');
                  print(_password.toString());
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LockerScreen(
                                log_id: _logID,
                                device_id: _deviceID,
                              )));
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

  Future<void> onPullToRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    getDevice();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // startTimer();
    getDevice();
    box.remove('group_id');
    box.remove('device_id');
    Timer.periodic(new Duration(seconds: 1), (timer) {
      debugPrint(timer.tick.toString());
      getDeviceNew();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        drawer: const WidgetDrawer(),
        backgroundColor: Colors.grey[300],
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 3,
          centerTitle: true,
          actions: [
            Builder(builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.green[200],
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            }),
          ],
          title: Row(
            children: [
              Image.asset(
                'assets/images/SOSSLOGO.png',
                width: 50,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Smart Parcel Box',
                style: TextStyle(color: Colors.green[200]),
              )
            ],
          ),
        ),
        body: _deviceModel?.data.status == true
            ? RefreshIndicator(
                onRefresh: onPullToRefresh,
                child: Container(
                  child: GridView.builder(
                      itemCount: _deviceModel!.data.message.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      padding: const EdgeInsets.all(10.0),
                      itemBuilder: (context, index) {
                        return InkWell(
                          //////
                          onTap: () {
                            print(
                                'Device ===> ## ${_deviceModel!.data.message[index].deviceId}');
                            print(
                                'deviceStatus ===> ###  ${_deviceModel!.data.message[index].deviceStatus}');
                            if (_deviceModel!.data.message[index].deviceSuccess
                                        .toString() ==
                                    '1' &&
                                _deviceModel!.data.message[index].deviceStatus
                                        .toString() !=
                                    '0') {
                              readDeviceId(
                                  _deviceModel!.data.message[index].deviceId);
                            }
                            if (_deviceModel!.data.message[index].deviceSuccess
                                    .toString() ==
                                '0') {
                              _showDepositDialog(
                                  context,
                                  '${_deviceModel!.data.message[index].deviceName}',
                                  _deviceModel!.data.message[index].groupId,
                                  _deviceModel!.data.message[index].deviceId);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Card(
                              color: _deviceModel!
                                          .data.message[index].deviceSuccess ==
                                      1
                                  ? Colors.red[400]
                                  : Colors.blue[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              elevation: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ชื่อช่อง: ${_deviceModel!.data.message[index].deviceName}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Image.asset(
                                      "assets/images/locker.png",
                                      width: size.width * 0.25,
                                    ),
                                    // _deviceModel!.data.message[index]
                                    //             .deviceStatus
                                    //             .toString() ==
                                    //         '0'
                                    //     ? Text('สถานะLocker: ไม่ได้ล็อค')
                                    //     : _deviceModel!.data.message[index]
                                    //                 .deviceStatus
                                    //                 .toString() ==
                                    //             '1'
                                    //         ? Text('สถานะLocker: ล็อค')
                                    //         : Text('สถานะLocker: ล็อค')
                                    // Text(
                                    //     'deviceStatus: ${_deviceModel!.data.message[index].deviceStatus}'),
                                    // Text(
                                    //     'deviceSuccess: ${_deviceModel!.data.message[index].deviceSuccess}')
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
