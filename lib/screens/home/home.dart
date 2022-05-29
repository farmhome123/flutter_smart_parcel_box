import 'dart:async';
import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparcelbox/components/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:smartparcelbox/models/deviceIdmodel.dart';
import 'package:smartparcelbox/models/devicemodel.dart';
import 'package:smartparcelbox/models/urladmodel.dart';
import 'package:smartparcelbox/screens/locker/depositlocker.dart';
import 'package:smartparcelbox/screens/locker/locker.dart';
import 'package:smartparcelbox/service.dart';
import 'package:video_player/video_player.dart';

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
  ModelUrlad? _modelUrlad;
  final box = GetStorage();
  late Timer _timer;
  int _start = 300;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;

  ChewieController? _chewieController1;
  ChewieController? _chewieController2;

  Future<void> getUrlads() async {
    final prefs = await SharedPreferences.getInstance();
    var _group_id = prefs.get('group_id');
    var url = Uri.parse(connect().url + "api/group/$_group_id");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _modelUrlad = modelUrladFromJson(response.body);
        });
        print(_modelUrlad);
        await initializePlayer();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> initializePlayer() async {
    try {
      var urlads = _modelUrlad?.data.message[0].groupAds;
      print('url ADS ===> ### $urlads');
      // _videoPlayerController1 = VideoPlayerController.network(
      //     "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4");
      _videoPlayerController1 = VideoPlayerController.network(urlads.toString());
      _videoPlayerController2 = VideoPlayerController.network(urlads.toString());
      await Future.wait(
          [_videoPlayerController1.initialize(), _videoPlayerController2.initialize()]);
      // await _createChewieController1();
      // await _createChewieController2();
      _createChewieController1();
      _createChewieController2();
      setState(() {
        _displayDialog(context);
      });
    } catch (e) {
      print(e);
    }
  }

  _createChewieController1() {
    _chewieController1 = ChewieController(
        videoPlayerController: _videoPlayerController1,
        autoPlay: true,
        looping: true,
        fullScreenByDefault: false,
        showControls: false);
  }

  _createChewieController2() {
    _chewieController2 = ChewieController(
        videoPlayerController: _videoPlayerController2,
        autoPlay: true,
        looping: true,
        fullScreenByDefault: false,
        showControls: false);
    setState(() {});
  }

  void _displayDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return WillPopScope(
          onWillPop: () async {
            setState(() {
              _chewieController1?.pause();
              _chewieController2?.pause();
              _timer.cancel();
              _start = 300;
            });
            startTimer();
            print('WillPopScope');
            Navigator.pop(context);
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(builder: (_) => HomeScreen()),
            //     (route) => false);
            return false;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _chewieController1?.pause();
                _chewieController2?.pause();
                _timer.cancel();
                _start = 300;
              });
              startTimer();

              Navigator.of(context).pop();
            },
            child: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                if (orientation == Orientation.portrait) {
                  return Scaffold(
                    body: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            height: double.infinity,
                            width: double.infinity,
                            child: _chewieController2 != null &&
                                    _chewieController2!
                                        .videoPlayerController.value.isInitialized
                                ? Chewie(
                                    controller: _chewieController2!,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                                      Text('Loading'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Scaffold(
                    body: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: _chewieController1 != null &&
                                    _chewieController1!
                                        .videoPlayerController.value.isInitialized
                                ? Chewie(
                                    controller: _chewieController1!,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 20),
                                      Text('Loading'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  void startTimer() async {
    // await initializePlayer();
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        print("_start ===> # ${_start}");
        if (_start == 0) {
          setState(() {
            timer.cancel();
            print('playyoutube !!!!!!');
            getUrlads();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void getDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var _group_id = prefs.get('group_id');
      print('group_id ==> ${_group_id}');

      var url = Uri.parse(connect().url + "api/device/group/group_id/${_group_id}");
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

      var url = Uri.parse(connect().url + "api/device/group/group_id/${_group_id}");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // print('getDeviceNew == 200');
        setState(() {
          _deviceModel_new = deviceModelFromJson(response.body);
          if (jsonEncode(_deviceModel_new!.data.message) !=
              jsonEncode(_deviceModel!.data.message)) {
            _deviceModel = _deviceModel_new;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void readDeviceId(deviceId) async {
    try {
      print("Function ---> readDeviceId");
      print('ID device ===> $deviceId');
      var url = Uri.parse(connect().url + "api/device/group/device_id/${deviceId}");
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
      onWillPopActive: true,
      context: context,
      content: Column(
        children: [
          Image.asset(
            "assets/images/locker.png",
            width: 100,
          ),
          Text(
            'ต้องการฝากของช่อง $lockname ',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      buttons: [
        DialogButton(
            color: Colors.green[300],
            child: Text(
              'ตกลง',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            onPressed: () {
              box.write('group_id', group_id);
              box.write('device_id', device_id);
              Navigator.of(context).pop();
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DepositlockerScreen()))
                  .then((value) {
                setState(() {
                  _start = 300;
                  startTimer();
                });
              });
            }),
      ],
      closeFunction: () {
        Navigator.of(context).pop();
        print('close');
        setState(() {
          _start = 300;
          startTimer();
        });
      },
    ).show();
  }

  _showPasswordDialog(context) async {
    String? _password;
    String? passwordDevice = _deviceIdModel!.data.message.devicePassword;
    String? _logID = _deviceIdModel!.data.message.logId.toString();
    String? _deviceID = _deviceIdModel!.data.message.deviceId.toString();
    print('passwordDevice ===> $passwordDevice');
    print('logID ==> $_logID');
    Alert(
      onWillPopActive: false,
      context: context,
      title: "กรุณากรอกรหัสผ่าน",
      content: Column(
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: "Password", icon: Icon(Icons.lock)),
            maxLines: 1,
            onChanged: (value) => _password = value,
            validator: (value) => value!.trim().isEmpty ? 'กรุณากรอก Password' : null,
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
                    ),
                  ),
                ).then((value) {
                  setState(() {
                    _start = 300;
                    startTimer();
                  });
                });
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
      ],
      closeFunction: () {
        Navigator.of(context).pop();
        print('close');
        setState(() {
          _start = 300;
          startTimer();
        });
      },
    ).show();
  }

  Future<void> onPullToRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    getDevice();
    // _timer.cancel();
    // _start = 3600;
    // startTimer();
  }

  Future<Null> checkCamera() async {
    Permission.camera.status.then((value) {
      print('cameraStatus ==> $value');
      if (value.isDenied) {
        Permission.camera
            .request()
            .then((value) => print('value after permisstion Camera ==> $value'));
      } else {
        return;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    // initializePlayer();
    super.initState();
    checkCamera();
    getDevice();
    box.remove('group_id');
    box.remove('device_id');
    Timer.periodic(new Duration(seconds: 1), (timer) {
      debugPrint(timer.tick.toString());
      getDeviceNew();
    });
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    _timer.cancel();
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController1?.dispose();
    _chewieController2?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _chewieController1?.pause();
          _chewieController2?.pause();
          _timer.cancel();
          _start = 300;
        });
        startTimer();
        print('WillPopScope');
        return false;
      },
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
                child: GestureDetector(
                  onTap: () {
                    // print("Tap Screen+++++++++++++++++ ");
                    // setState(() {
                    //   _timer.cancel();
                    //   _start = 3600;
                    // });
                    // startTimer();
                  },
                  child: Container(
                    child: GridView.builder(
                        itemCount: _deviceModel!.data.message.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        padding: const EdgeInsets.all(10.0),
                        itemBuilder: (context, index) {
                          return InkWell(
                            //////
                            onTap: () {
                              print("Tap Screen+++++++++++++++++ ");
                              setState(() {
                                _timer.cancel();
                                // _start = 3600;
                              });
                              // startTimer();
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
                                readDeviceId(_deviceModel!.data.message[index].deviceId);
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
                                color: _deviceModel!.data.message[index].deviceSuccess
                                                .toString() !=
                                            '0' &&
                                        _deviceModel!.data.message[index].deviceStatus !=
                                            '0'
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
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
