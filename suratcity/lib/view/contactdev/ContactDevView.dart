import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';

var data;

class ContactDevView extends StatefulWidget {
  ContactDevView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _ContactDevViewState createState() => _ContactDevViewState();
}

class _ContactDevViewState extends State<ContactDevView> {
  final _detail = TextEditingController();
  final _fullname = TextEditingController();
  final _phone = TextEditingController();
  bool _validateDetail = false;
  bool _validateFullname = false;
  bool _validatePhone = false;

  var osName = "";

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initPlatformState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        osName = "Android " + deviceData["version.release"];
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        osName = "IOS " + deviceData["data.systemVersion"];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
      print(_deviceData.toString());
      print(osName.toString());
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  insertData() async {
    Map _map = {};
    _map.addAll({
      "detail": _detail.text,
      "name": _fullname.text,
      "email": _phone.text,
    });
    var body = json.encode(_map);
    return postContactData(http.Client(), body, _map);
  }

  Future<List<AllList>> postContactData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().contactCity),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    data = json.decode(response.body);
    print("data" + data.toString());
    var status = data['status'].toString();
    if (status == "success") {
      Toast.show("ส่งข้อมูลเรียบร้อยแล้ว", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      //Navigator.pop(context);
      EasyLoading.dismiss();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FrontPageView(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "แจ้งปัญหา/ติดต่อผู้พัฒนา",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        /*decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              Color(0xFF65DF92),
              Color(0xFF10B3A8),
              Color(0xFF11B4A8),
            ],
          ),
        ),*/
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 5 * 24.0,
                      child: TextField(
                        controller: _detail,
                        maxLines: 5,
                        decoration: new InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintText: 'รายละเอียด',
                          errorText:
                              _validateDetail ? 'กรุณากรอกรายละเอียด' : null,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _fullname,
                        decoration: new InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintText: 'ชื่อ-สกุล',
                          errorText:
                              _validateFullname ? 'กรุณากรอกชื่อ-สกุล' : null,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _phone,
                        decoration: new InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintText: 'เบอร์โทรศัพท์',
                          errorText:
                              _validatePhone ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _detail.text.isEmpty
                                ? _validateDetail = true
                                : _validateDetail = false;
                            _fullname.text.isEmpty
                                ? _validateFullname = true
                                : _validateFullname = false;
                            _phone.text.isEmpty
                                ? _validatePhone = true
                                : _validatePhone = false;

                            if (!_validateDetail &&
                                !_validateFullname &&
                                !_validatePhone) {
                              EasyLoading.show(status: 'loading...');
                              insertData();
                            }
                          });
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        child: Container(
                          width: 300,
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            gradient: new LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                            ),
                          ),
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            "ตกลง",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchInBrowser("http://cityvariety.co.th/");
                },
                child: Container(
                  margin: EdgeInsets.only(top: 28),
                  alignment: Alignment.center,
                  child: Text(
                    "บริษัท ซิตี้วาไรตี้ คอร์เปอเรชั่น จำกัด",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      //decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                alignment: Alignment.center,
                child: Text(
                  "โทร 086-4908961 086-4700370 086-4810145 074-559304 หรือ Line ID : @cityvariety",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      /*child: Image.asset(
                            'assets/images/favicon.png',
                            height: 48,
                            width: 48,
                          ),*/
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 48,
                      ),
                      margin: EdgeInsets.all(8),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Version " +
                            _packageInfo.version +
                            " On " +
                            osName),
                        Row(
                          children: [
                            Text("Powered by "),
                            Text(
                              "CityVariety Co.,Ltd,",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
