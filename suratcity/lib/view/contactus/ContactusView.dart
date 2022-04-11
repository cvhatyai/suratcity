import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';
import 'FollowContactusListView.dart';

var data;

class ContactusView extends StatefulWidget {
  ContactusView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _ContactusViewState createState() => _ContactusViewState();
}

class _ContactusViewState extends State<ContactusView> {
  final _detail = TextEditingController();
  final _subject = TextEditingController();
  final _fullname = TextEditingController();
  final _phone = TextEditingController();

  //final _fax = TextEditingController();
  final _address = TextEditingController();
  bool _validateSubject = false;
  bool _validateDetail = false;
  bool _validateFullname = false;
  bool _validatePhone = false;
  bool _validateAddress = false;

  //siteDetail
  var name = "";
  var address = "";
  var faxphone = "";
  var fax = "";
  var phone = "";
  var email = "";
  var icon = "";
  var mapPic = "";
  double lat = 0;
  double lng = 0;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  var user = User();
  bool isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();

    getSiteDetail();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
      if (isLogin) {
        _phone.text = user.phone;
        _fullname.text = user.fullname;
      }
    });
  }

  insertData() async {
    Map _map = {};
    _map.addAll({
      "detail": _detail.text, //
      "subject": _subject.text, //
      "name": _fullname.text, //
      //"email": _phone.text, //
      "address": _address.text, //
      "tel": _phone.text, //
      //"fax": _fax.text, //
      "uid": user.uid,
    });
    print("_map" + _map.toString());
    var body = json.encode(_map);
    return postContactData(http.Client(), body, _map);
  }

  Future<List<AllList>> postContactData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().contactusAdd),
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
          builder: (context) => FollowContactusListView(
            isHaveArrow: "1",
          ),
        ),
      );
    }
  }

  getSiteDetail() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postSiteDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postSiteDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().siteDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      name = rs["name"].toString();
      address = rs["address"].toString();
      faxphone = rs["faxphone"].toString();
      phone = rs["phone"].toString();
      fax = rs["fax"].toString();
      email = rs["email"].toString();
      icon = rs["icon"].toString();
      mapPic = rs["map"].toString();
      lat = rs["lat"];
      lng = rs["lng"];
    });
  }

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ติดต่อเจ้าหน้าที่",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (icon != "")
                      Image.network(
                        icon,
                        height: 96,
                      ),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        address,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Wrap(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (phone != "")
                            GestureDetector(
                              onTap: () {
                                _makePhoneCall("tel:$phone");
                              },
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text("โทร : "),
                                  Text(
                                    phone,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          if (fax != "")
                            Text(
                              " แฟกซ์ : " + fax,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Text(
                        email,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
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
                    //phone
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
                    //name
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
                    //fax
                    /*Container(
                      margin: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _fax,
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
                          hintText: 'โทรสาร(เว้นว่างได้)',
                        ),
                      ),
                    ),*/
                    //subject
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _subject,
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
                          hintText: 'ชื่อเรื่อง',
                          errorText:
                              _validateSubject ? 'กรุณากรอกชื่อเรื่อง' : null,
                        ),
                      ),
                    ),
                    //address
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: TextField(
                        controller: _address,
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
                          hintText: 'ที่อยู่',
                          errorText:
                              _validateAddress ? 'กรุณากรอกที่อยู่' : null,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
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
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _detail.text.isEmpty
                                ? _validateDetail = true
                                : _validateDetail = false;
                            _subject.text.isEmpty
                                ? _validateSubject = true
                                : _validateSubject = false;
                            _address.text.isEmpty
                                ? _validateAddress = true
                                : _validateAddress = false;
                            _fullname.text.isEmpty
                                ? _validateFullname = true
                                : _validateFullname = false;
                            _phone.text.isEmpty
                                ? _validatePhone = true
                                : _validatePhone = false;

                            if (!_validateDetail &&
                                !_validateFullname &&
                                !_validateAddress &&
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
                    //map
                    if (lat != 0)
                      Container(
                        margin: EdgeInsets.only(top: 32),
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: GoogleMap(
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 18,
                          ),
                          key: ValueKey('uniqueey'),
                          onMapCreated: _onMapCreated,
                          markers: {
                            Marker(
                                markerId: MarkerId('anyUniqueId'),
                                position: LatLng(lat, lng),
                                infoWindow: InfoWindow(title: 'Some Location'))
                          },
                        ),
                      ),
                    if (lat != 0)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () {
                            var urlMap =
                                "https://www.google.com/maps/dir/?api=1&destination=" +
                                    lat.toString() +
                                    "," +
                                    lng.toString();
                            _launchInBrowser(urlMap);
                          },
                          child: Text('นำทาง'),
                        ),
                      ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          var urlMap = Info().baseUrl;
                          _launchInBrowser(urlMap);
                        },
                        child: Text('เข้าสู่เว็บไซต์เทศบาล'),
                      ),
                    ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () {
                          /*var urlMap = "https://www.facebook.com/suratcity";
                          _launchInBrowser(urlMap);*/
                        },
                        child: Text('Facebookเทศบาล'),
                      ),
                    )
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
