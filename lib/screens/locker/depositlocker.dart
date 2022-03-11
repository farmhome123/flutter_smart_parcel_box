import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:smartparcelbox/Widget/search_widget.dart';
import 'package:smartparcelbox/models/deviceIdmodel.dart';
import 'package:smartparcelbox/models/getnameimagemodel.dart';
import 'package:smartparcelbox/models/userallmodel.dart';
import 'package:smartparcelbox/models/userlisemodel.dart';
import 'package:smartparcelbox/screens/home/home.dart';
import 'package:smartparcelbox/service.dart';
import 'package:image/image.dart' as img;

class DepositlockerScreen extends StatefulWidget {
  const DepositlockerScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DepositlockerScreen> createState() => _DepositlockerScreenState();
}

class _DepositlockerScreenState extends State<DepositlockerScreen> {
  int _currentStep = 0;
  bool isloading = false;
  final box = GetStorage();
  UserAllModel? _userAllModel;
  Timer? debouncer;
  String query = '';
  List<UserList>? users;
  String nameselect = "";
  GetNameModel? _getNameModel;
  String namefile = '';
  File? _image;
  final imagePicker = ImagePicker();
  bool isShowLocker = false;
  Timer? _timer;
  int _start = 30;
  DeviceIdModel? _deviceIdModel;

  XFile? pictureFile;
  bool isloaddinguploadimage = true;

  CameraController? controller_camera;
  Future<void>? _initializeControllerFuture; //Future to wait un

  _stepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else {
      return StepState.editing;
    }
  }

  Future<List<UserList>> getUsers(String query) async {
    final url = Uri.parse(connect().url + 'api/user/user/all');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _userAllModel = userAllModelFromJson(response.body);
      });
      final List users = json.decode(json.encode(_userAllModel!.data.message));

      return users.map((json) => UserList.fromJson(json)).where((user) {
        final nameLower = user.userName.toLowerCase();
        final emailLower = user.userEmail.toLowerCase();
        final telLower = user.userTel.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            emailLower.contains(searchLower) ||
            telLower.contains(searchLower);
      }).toList();
    } else {
      throw Exception();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  @override
  void dispose() {
    debouncer?.cancel();
    
    super.dispose();
  }

  void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    if (debouncer != null) {
      debouncer!.cancel();
    }

    debouncer = Timer(duration, callback);
  }

  Future init() async {
    final users = await getUsers(query);
    setState(() => this.users = users);
  }

  void getNameImage() async {
    var url = Uri.parse(connect().url + "api/device/log/add");
    var random = Random();
    var valueRandom = random.nextInt(900000) + 100000;
    print(num);
    var body = {
      "group_id": box.read('group_id').toString(),
      "device_id": box.read('device_id').toString(),
      "user_id": box.read('user_id').toString(),
      "device_password": valueRandom.toString()
    };
    print('body ===>### ${body}');
    try {
      var response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        setState(() {
          _getNameModel = getNameModelFromJson(response.body);
        });
        print(jsonEncode(_getNameModel));
        print('filename ===> ${_getNameModel!.data.img}');
        var str = _getNameModel!.data.img.toString();
        print(str.substring(0, str.indexOf('.png')));
        setState(() {
          namefile = str.substring(0, str.indexOf('.png'));
        });
        print('namefile ===>### $namefile');
      } else {
        print('Error Statuscode : ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  // getImage() async {
  //   var source = ImageSource.camera;
  //   XFile? image = await imagePicker.pickImage(
  //       source: source,
  //       imageQuality: 50,
  //       preferredCameraDevice: CameraDevice.front);
  //   if (image != null) {
  //     setState(() {
  //       _image = File(image.path);
  //     });
  //   }
  // }

  Future getImage() async {
    var source = ImageSource.camera;
    XFile? image = await imagePicker.pickImage(
        source: source, preferredCameraDevice: CameraDevice.rear);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }
  // Future getImage() async {
  //   XFile? image = pictureFile;

  //   if (image != null) {
  //     setState(() {
  //       _image = File(image.path);
  //     });
  //   }
  // }

  uploadImage() async {
    print('namefile ===> ### ${namefile}');
    try {
      if (_image != null) {
        img.Image? imageTemp = img.decodeImage(_image!.readAsBytesSync());
        img.Image resizedImg = img.copyResize(imageTemp!, height: 500);

        var request = new http.MultipartRequest(
            'POST',
            Uri.parse(
                connect().url + "upload-images/upload-image/${namefile}"));
        var multipartFile = new http.MultipartFile.fromBytes(
          'file',
          img.encodeJpg(resizedImg),
          filename: 'resized_image.jpg',
          contentType: MediaType.parse('image/jpeg'),
        );

        request.files.add(multipartFile);
        var response = await request.send();
        print(response.statusCode);
        if (response.statusCode == 200) {
          print('อัพโหลดรูปภาพสำเร็จ');
          print(response);
          setState(() {
            isloaddinguploadimage = false;
          });
          openLocker();
        } else {
          print(response.statusCode);
          print('อัพโหลดรูปภาพไม่สำเร็จ');
        }
        response.stream.transform(utf8.decoder).listen((value) {
          print(value);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void openLocker() async {
    var device_id = await box.read("device_id");
    try {
      print('device_id ===> ## $device_id');
      var putOpenlocker = Uri.parse(
          connect().url + "api/device/device/managerdevice/${device_id}");
      var body = {
        "device_success": "0",
        "device_status": "0",
        "device_check": "1"
      };
      print(body);
      var response = await http.put(putOpenlocker, body: body);
      if (response.statusCode == 200) {
        print(jsonEncode(response.body));
        print('เปิดประตูlockerเรียบร้อยแล้ว');
        getDeviceStatus();
        setState(() {
          isShowLocker = true;
        });
        isShowLocker == true ? _showDialogOpenLocker(context) : null;
      } else {
        print(response.statusCode);
        print('เปิดประตูlocker ไม่สำเร็จ');
      }
    } catch (e) {
      print(e);
    }
  }

  void getDeviceStatus() async {
    var device_id = await box.read('device_id');
    print('device_id ===> ## $device_id');
    var getdeviceID =
        Uri.parse(connect().url + "api/device/group/device_id/${device_id}");
    try {
      var oneSec = const Duration(seconds: 1);
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) async {
          var response = await http.get(getdeviceID);
          if (response.statusCode == 200) {
            setState(() {
              _deviceIdModel = deviceIdModelFromJson(response.body);
            });
            print(_deviceIdModel);
            print(
                'device_success ===> ${_deviceIdModel!.data.message.deviceSuccess}');
            if (_deviceIdModel!.data.message.deviceStatus.toString() == '2') {
              sendLine();
              _timer!.cancel();
            }
          } else {
            print('error ===> ${response.statusCode}');
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void _backupgetDeviceStatus() async {
    var device_id = await box.read('device_id');
    print('device_id ===> ## $device_id');
    var getdeviceID =
        Uri.parse(connect().url + "api/device/group/device_id/${device_id}");
    try {
      var oneSec = const Duration(seconds: 1);
      _timer = new Timer.periodic(
        oneSec,
        (Timer timer) async {
          if (_start == 0) {
            setState(() {
              timer.cancel();
            });
            // Navigator.pop(context);
            // Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          } else {
            setState(() {
              _start--;
            });
            print('getDeviceStatus ===> ### $_start');
            var response = await http.get(getdeviceID);
            if (response.statusCode == 200) {
              setState(() {
                _deviceIdModel = deviceIdModelFromJson(response.body);
              });
              print(_deviceIdModel);
              print(
                  'device_success ===> ${_deviceIdModel!.data.message.deviceSuccess}');
              if (_deviceIdModel!.data.message.deviceStatus.toString() != '0' &&
                  _deviceIdModel!.data.message.deviceSuccess.toString() !=
                      '0') {
                sendLine();
                _timer!.cancel();
              }
            } else {
              print('error ===> ${response.statusCode}');
              // Navigator.pop(context);
              // Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
            }
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void sendLine() async {
    var device_id = await box.read('device_id');
    var urlsendline =
        Uri.parse(connect().url + "api/linebot/send/step/1/${device_id}");
    try {
      var response = await http.get(urlsendline);
      if (response.statusCode == 200) {
        print('sendLine success');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        Fluttertoast.showToast(
            msg: "ฝากของเรียบร้อยแล้ว",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print('error ===> ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black54,
        ),
        title: Text(
          'การฝากของ',
          style: TextStyle(color: Colors.black54),
        ),
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: isloading == false
            ? Column(
                children: [
                  Expanded(
                    child: Stepper(
                      physics: ClampingScrollPhysics(),
                      type: StepperType.horizontal,
                      controlsBuilder:
                          (BuildContext context, ControlsDetails controls) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              if (_currentStep == 0)
                                ElevatedButton(
                                  onPressed: () {
                                    if (!nameselect.isEmpty) {
                                      setState(() {
                                        if (_currentStep < 3 - 1) {
                                          _currentStep += 1;
                                        } else {
                                          _currentStep = 0;
                                        }
                                      });
                                    } else {
                                      print('กรุณาเลือกผู้รับ');
                                      _showAlertselect(context);
                                    }
                                  },
                                  child: const Text('ถัดไป'),
                                ),
                              // if (_currentStep != 0)
                              //   TextButton(
                              //     onPressed: controls.onStepCancel,
                              //     child: const Text(
                              //       'BACK',
                              //       style: TextStyle(color: Colors.grey),
                              //     ),
                              //   ),
                              if (_currentStep == 1)
                                ElevatedButton(
                                  onPressed: () {
                                    if (_image != null) {
                                      print('บันทึกข้อมูล');
                                      setState(() {
                                        if (_currentStep < 3 - 1) {
                                          _currentStep += 1;
                                        } else {
                                          _currentStep = 0;
                                        }
                                      });
                                    } else {
                                      print('กรุณาถ่ายรูป');
                                      _showAlertTakePhoto(context);
                                    }
                                  },
                                  child: const Text('ถัดไป'),
                                ),
                              if (_currentStep == 2)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red),
                                  onPressed: () {
                                    print('DONE');
                                    Navigator.pop(context);
                                  },
                                  child: const Text('ยกเลิกการฝาก'),
                                ),
                            ],
                          ),
                        );
                      },
                      currentStep: _currentStep,
                      steps: [
                        Step(
                          title: const Text('เลือกผู้รับ'),
                          content: users != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text('ชื่อผู้รับ: '),
                                        Text(
                                          "${nameselect}",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    buildSearch(),
                                    const Divider(),
                                    Container(
                                      height: size.height * 0.5,
                                      child: ListView.builder(
                                          itemCount: users!.length,
                                          itemBuilder: (context, index) {
                                            final user = users![index];
                                            return buildBook(user);
                                          }),
                                    ),
                                    const Divider(),
                                  ],
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                          state: _stepState(0),
                          isActive: _currentStep == 0,
                        ),
                        Step(
                          title: const Text('ข้อมูลผู้ฝาก'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row(
                              //   children: [
                              //     Text('  group_id: ' +
                              //         box.read('group_id').toString()),
                              //     Text('  device_id: ' +
                              //         box.read('device_id').toString()),
                              //     Text('  user_id: ' +
                              //         box.read('user_id').toString())
                              //   ],
                              // ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('ชื่อผู้รับ: '),
                                  Text(
                                    "${nameselect}",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: const Text(
                                  'อัพโหลดรูปภาพ',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              // FlatButton(
                              //     onPressed: () => uploadImage(),
                              //     child: Text('upload')),
                              // FlatButton(
                              //     onPressed: () =>
                              //         _showDialogOpenLocker(context),
                              //     child: Text('openLocker')),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Container(
                                    color: Colors.green[50],
                                    width: size.width * 0.8,
                                    height: size.height * 0.5,
                                    child: _image == null
                                        ? Center(
                                            child: Text(
                                            'กรุณาถ่ายรูป',
                                            style: TextStyle(fontSize: 20),
                                          ))
                                        : Image.file(File(_image!.path)),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Center(
                              //     child: Container(
                              //       color: Colors.green[50],
                              //       width: size.width * 0.8,
                              //       height: size.height * 0.5,
                              //       child: _image == null
                              //           ? CameraPreview(controller_camera)
                              //           : Image.file(_image!),
                              //     ),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: FutureBuilder<void>(
                              //     future: _initializeControllerFuture,
                              //     builder: (context, snapshot) {
                              //       if (snapshot.connectionState ==
                              //           ConnectionState.done) {
                              //         // If the Future is complete, display the preview.
                              //         return Container(
                              //             color: Colors.green[50],
                              //             width: size.width * 0.8,
                              //             height: size.height * 0.5,
                              //             child: _image != null
                              //                 ? Image.file(_image!)
                              //                 : CameraPreview(
                              //                     controller_camera!));
                              //       } else {
                              //         // Otherwise, display a loading indicator.
                              //         return Center(
                              //             child: CircularProgressIndicator());
                              //       }
                              //     },
                              //   ),
                              // ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green[100]!,
                                        blurRadius: 2.0,
                                        spreadRadius: 0.0,
                                        offset: Offset(0,
                                            3.0), // shadow direction: bottom right
                                      )
                                    ],
                                  ),
                                  width: size.width * 0.7,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    color: Colors.green[300],
                                    textColor: Colors.white,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "ถ่ายรูป",
                                          style: TextStyle(
                                            fontSize: 18,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Icon(Icons.camera_alt)
                                      ],
                                    ),
                                    onPressed: () async {
                                      print('ถ่ายรูป');
                                      // getImage();
                                      // await availableCameras().then(
                                      //   (value) => Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => CameraPage(
                                      //         cameras: value,
                                      //       ),
                                      //     ), // MaterialPageRoute
                                      //   ),
                                      // );
                                      // pictureFile = await controller.takePicture();
                                      // await _initializeControllerFuture;
                                      // pictureFile = await controller_camera!
                                      //     .takePicture();
                                      // setState(() {});
                                      getImage();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          state: _stepState(1),
                          isActive: _currentStep == 1,
                        ),
                        Step(
                          title: const Text('สรุปการฝาก'),
                          content: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('ชื่อผู้รับ: '),
                                    Text(
                                      "${nameselect}",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('รูปผู้ฝาก'),
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: _image != null
                                          ? Image.file(
                                              _image!,
                                              height: size.height * 0.5,
                                            )
                                          : Text('...'),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green[100]!,
                                              blurRadius: 2.0,
                                              spreadRadius: 0.0,
                                              offset: Offset(0,
                                                  3.0), // shadow direction: bottom right
                                            )
                                          ],
                                        ),
                                        width: size.width * 0.7,
                                        child: FlatButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          padding: EdgeInsets.all(10),
                                          color: Colors.green[300],
                                          textColor: Colors.white,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "ยืนยันการฝาก",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                            print('บันทึกข้อมูล');
                                            getNameImage();
                                            _showAlertSave(context);
                                            // getImage();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          state: _stepState(2),
                          isActive: _currentStep == 2,
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  _showAlertselect(context) async {
    Alert(context: context, content: Text('กรุณาเลือกผู้รับ'), buttons: [
      DialogButton(
          child: Text(
            'ตกลง',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          })
    ]).show();
  }

  _showAlertTakePhoto(context) async {
    Alert(context: context, content: Text('กรุณาถ่ายรูป'), buttons: [
      DialogButton(
          child: Text(
            'ตกลง',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          })
    ]).show();
  }

  _showAlertSave(context) async {
    Alert(context: context, content: Text('ต้องการบันทึกข้อมูล'), buttons: [
      DialogButton(
          child: Text(
            'ตกลง',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          onPressed: () {
            isloaddinguploadimage == true
                ? showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    })
                : Navigator.pop(context);

            uploadImage();
          }),
      DialogButton(
          color: Colors.red,
          child: Text(
            'ยกเลิก',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          })
    ]).show();
  }

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'เบอร์โทรศัพท์',
        onChanged: searchBook,
      );

  Future searchBook(String query) async => debounce(() async {
        final users = await getUsers(query);
        print('query ${query}');
        print('users ${users}');
        if (!mounted) return;
        setState(() {
          this.query = query;
          this.users = users;
        });
      });
  Widget buildBook(UserList user) => ListTile(
        title: Text('Name: ' + user.userName),
        onTap: () {
          print('Name: ' + user.userName + ' Id: ' + user.userId.toString());
          setState(() {
            nameselect = user.userName;
            box.write('user_id', user.userId.toString());
          });
        },
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ' + user.userEmail),
            Text('Tel: ' + user.userTel)
          ],
        ),
      );

  _showDialogOpenLocker(context) async {
    Alert(
        context: context,
        title: "ประตูล็อคเกอร์เปิดแล้ว!",
        content: Column(
          children: [
            const Text('นำของเข้าเรียบร้อยแล้วกรุณาปิดประตูล็อคเกอร์!'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Icon(
                Icons.lock_open,
                size: 80,
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            color: Colors.red[600],
            onPressed: () async {
              _timer!.cancel();
              if (!_timer!.isActive) {
                // Navigator.pop(context);
                // Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
            },
            child: Text(
              "ยกเลิกการฝาก",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
