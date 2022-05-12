import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

var data;
List<String> imgList = [];
List<String> imgList2 = [];
List<String> imgList3 = [];
List<String> imgList4 = [];

//upload
Map<String, String> _images;
List<File> _filesImage = List<File>();
int fileAllTotal = 0;
Map<String, String> _dataFiles;
List<File> _filesAll = List<File>();

Map<String, String> _images2;
List<File> _filesImage2 = List<File>();
int fileAllTotal2 = 0;
Map<String, String> _dataFiles2;
List<File> _filesAll2 = List<File>();

//upload

//dropdown
var arrMap;
String cateVal = "";
Map<int, String> dataCateMap = {0: "-- เลือกหมวด --"};
//dropdown

//dropdown2
var arrMap2;
String cateVal2 = "";
Map<int, String> dataCateMap2 = {0: "รอตรวจสอบ"};
//dropdown2

class ComplainAdminDetailView extends StatefulWidget {
  ComplainAdminDetailView({Key key, this.topicID, this.title = ""})
      : super(key: key);
  final String topicID;
  final String title;

  @override
  _ComplainAdminDetailViewState createState() =>
      _ComplainAdminDetailViewState();
}

class _ComplainAdminDetailViewState extends State<ComplainAdminDetailView> {
  var user = User();
  bool isLogin = false;

  final _replyByAdmin = TextEditingController();
  final _replyFinish = TextEditingController();

  var subject = "";
  var name = "";
  var create_date = "";
  var near_location = "";
  var phone = "";
  var description = "";
  var type_name = "";
  var type_id = "";
  var status_int = "";
  var status = "";
  var reply_by_admin = "";
  var reply_finish = "";

  var latitude = "";
  var longtitude = "";
  int imgcount = 0;
  int imgcount2 = 0;
  int imgcount3 = 0;
  int imgcount4 = 0;

  //setup image files1
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  FileType fileType;
  int filesImageTotal = 0;
  var progress;

  //setup image files2
  String fileName2;
  String path2;
  Map<String, String> paths2;
  List<String> extensions2;
  bool isLoadingPath2 = false;
  FileType fileType2;
  int filesImageTotal2 = 0;
  var progress2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
    _clearUiView();
    getDetail();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
    });
  }

  @override
  void dispose() {
    cateVal = "";
    cateVal2 = "";
    arrMap = null;
    arrMap2 = null;
    _filesAll.clear();
    _filesAll2.clear();
    _dataFiles.clear();
    _dataFiles2.clear();
    super.dispose();
  }

  void _clearUiView() {
    setState(() {
      _images = null;
      _images2 = null;
    });

    print("_filesAll : " + _filesAll.toString());
    print("_filesAll : " + _filesAll2.toString());
    print("_filesAll : " + _dataFiles.toString());
    print("_filesAll : " + _dataFiles2.toString());
  }

  //dropdown1

  String dropdownValue = (cateVal != "") ? cateVal : "0";

  getCateList() {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateInformList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCateData(response.body);
  }

  List<AllList> parseCateData(String responseBody) {
    print("responseBody" + responseBody.toString());
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMap = parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    print("arrMap" + arrMap.toString());

    Map<int, String> tmpDataCateMap;
    tmpDataCateMap =
        Map.fromIterable(arrMap, key: (e) => e.id, value: (e) => e.subject);
    dataCateMap.addAll(tmpDataCateMap);

    print("dataCateMap" + dataCateMap.toString());

    setState(() {});

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  Widget dropDownCate() {
    return (arrMap != null && arrMap.length != 0)
        ? DropdownButton<String>(
            value: dropdownValue,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_outlined),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Color(0xFF7C1B6A)),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
                cateVal = dropdownValue;
              });
            },
            items: dataCateMap.entries
                .map<DropdownMenuItem<String>>(
                    (MapEntry<int, String> e) => DropdownMenuItem<String>(
                          value: e.key.toString(),
                          child: Text(
                            e.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                .toList(),
          )
        : Container();
  }

  //dropdown1

  //dropdown2

  String dropdownValue2 = (cateVal2 != "") ? cateVal2 : "0";

  getCateList2() {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postCateData2(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData2(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateInformStatusList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCateData2(response.body);
  }

  List<AllList> parseCateData2(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMap2 = parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    Map<int, String> tmpDataCateMap2;
    tmpDataCateMap2 =
        Map.fromIterable(arrMap2, key: (e) => e.id, value: (e) => e.subject);
    dataCateMap2.addAll(tmpDataCateMap2);

    print("dataCateMap2" + dataCateMap2.toString());
    setState(() {});

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  Widget dropDownCate2() {
    return (arrMap2 != null && arrMap2.length != 0)
        ? DropdownButton<String>(
            value: dropdownValue2,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_outlined),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Color(0xFF7C1B6A)),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            onChanged: (String newValue2) {
              setState(() {
                dropdownValue2 = newValue2;
                cateVal2 = dropdownValue2;
              });
            },
            items: dataCateMap2.entries
                .map<DropdownMenuItem<String>>(
                    (MapEntry<int, String> e) => DropdownMenuItem<String>(
                          value: e.key.toString(),
                          child: Text(
                            e.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                .toList(),
          )
        : Container();
  }

  //dropdown2

  getDetail() async {
    Map _map = {};
    _map.addAll({
      "id": widget.topicID,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postDetail(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().informDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      name = data['name'].toString();
      create_date = data['create_date'].toString();
      near_location = data['near_location'].toString();
      phone = data['phone'].toString();
      description = data['description'].toString();
      type_id = data['type_id'].toString();

      cateVal = type_id;
      dropdownValue = cateVal;

      type_name = data['type_name'].toString();
      status = data['status'].toString();

      status_int = data['status_int'].toString();
      cateVal2 = status_int;
      dropdownValue2 = cateVal2;

      reply_by_admin = data['reply_by_admin'].toString();

      if (reply_by_admin != "") {
        _replyByAdmin.text = reply_by_admin;
      }

      reply_finish = data['reply_finish'].toString();

      if (reply_finish != "") {
        _replyFinish.text = reply_finish;
      }

      latitude = data['latitude'].toString();
      longtitude = data['longtitude'].toString();

      imgcount = data['imgcount'];
      if (imgcount > 0) {
        imgList.clear();
        var tmp = data['img'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList.addAll(tmp.split(","));
      }

      imgcount2 = data['imgcount2'];
      if (imgcount2 > 0) {
        imgList2.clear();
        var tmp = data['img2'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList2.addAll(tmp.split(","));
      }

      imgcount3 = data['imgcount3'];
      if (imgcount3 > 0) {
        imgList3.clear();
        var tmp = data['img3'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList3.addAll(tmp.split(","));
      }

      imgcount4 = data['imgcount4'];
      if (imgcount4 > 0) {
        imgList4.clear();
        var tmp = data['img4'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList4.addAll(tmp.split(","));
      }
    });
    print("cateVal1" + cateVal);
    print("cateVal2" + dropdownValue);
    print("cateVal3" + cateVal2);
    print("cateVal4" + dropdownValue2);

    Timer(Duration(seconds: 1), () => getCateList());
    Timer(Duration(seconds: 1), () => getCateList2());

    EasyLoading.dismiss();
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

  BoxDecoration boxWhite() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(9.0),
      ),
      border: Border.all(
        color: Color(0xFF8C1F78),
        width: 1.0,
      ),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );
  }

  //เปิดภาพ1
  void _openFileImagesExplorer() async {
    try {
      path = null;
      paths = await FilePicker.getMultiFilePath(
          type: fileType != null ? fileType : FileType.image,
          allowedExtensions: extensions);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = path != null
          ? path.split('/').last
          : paths != null
              ? paths.keys.toString()
              : '...';

      if (paths != null) {
        if (_images != null) {
          for (var i = 0; i < paths.length; i++) {
            var keys = paths.keys.toList()[i].toString();
            var values = paths.values.toList()[i].toString();
            _images[keys] = values;
          }
        } else {
          _images = paths;
        }
        print('wit img storage: ${_images}');
        filesImageTotal = _images.length;
        fileAllTotal = filesImageTotal;
      }
    });
  }

  //เปิดภาพ2
  void _openFileImagesExplorer2() async {
    try {
      path2 = null;
      paths2 = await FilePicker.getMultiFilePath(
          type: fileType2 != null ? fileType2 : FileType.image,
          allowedExtensions: extensions);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath2 = false;
      fileName2 = path2 != null
          ? path2.split('/').last
          : paths2 != null
              ? paths2.keys.toString()
              : '...';

      if (paths2 != null) {
        if (_images2 != null) {
          for (var i = 0; i < paths2.length; i++) {
            var keys2 = paths2.keys.toList()[i].toString();
            var values2 = paths2.values.toList()[i].toString();
            _images2[keys2] = values2;
          }
        } else {
          _images2 = paths2;
        }
        print('wit img storage2: ${_images2}');
        filesImageTotal2 = _images2.length;
        fileAllTotal2 = filesImageTotal2;
      }
    });
  }

  //updateComplain

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  updateComplain() async {
    var uri = Uri.parse(Info().informUpdate);
    var request = http.MultipartRequest('POST', uri);

    //image before
    if (_images != null) {
      _dataFiles = {..._images};
    }

    if (_dataFiles != null) {
      for (int i = 0; i < _dataFiles.length; i++) {
        var file = await getImageFileFromAsset(
            _dataFiles.values.toList()[i].toString());
        setState(() {
          _filesAll.add(file);
        });
      }
    }

    //image after
    if (_images2 != null) {
      _dataFiles2 = {..._images2};
    }

    if (_dataFiles2 != null) {
      for (int i = 0; i < _dataFiles2.length; i++) {
        var file = await getImageFileFromAsset(
            _dataFiles2.values.toList()[i].toString());
        setState(() {
          _filesAll2.add(file);
        });
      }
    }

    request.fields['id'] = widget.topicID;
    request.fields['reply_by_admin'] = _replyByAdmin.text;
    request.fields['reply_finish'] = _replyFinish.text;
    request.fields['uid'] = user.uid;
    request.fields['type_id'] = cateVal;
    request.fields['status'] = cateVal2;

    if (_filesAll.length > 0) {
      var len_file = _filesAll.length;
      print("wit len file $len_file");
      for (int i = 0; i < len_file; i++) {
        var ext = _filesAll[i].path.split('.').last;
        var file = await http.MultipartFile.fromPath(
            'file[$i]', _filesAll[i].path,
            contentType: MediaType('image', ext));
        //add multipart to request
        request.files.add(file);
      }
    }

    if (_filesAll2.length > 0) {
      var len_file = _filesAll2.length;
      print("wit len file $len_file");
      for (int i = 0; i < len_file; i++) {
        var ext = _filesAll2[i].path.split('.').last;
        var file = await http.MultipartFile.fromPath(
            'file2[$i]', _filesAll2[i].path,
            contentType: MediaType('image', ext));
        //add multipart to request
        request.files.add(file);
      }
    }

    /*print("id : " + widget.topicID);
    print("reply_by_admin : " + _replyByAdmin.text);
    print("reply_finish : " + _replyFinish.text);
    print("uid : " + user.uid);
    print("type_id : " + cateVal);
    print("status : " + cateVal2);*/

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("wit after submit");
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      final data = jsonDecode(response.body);
      print('wit data: ' + data.toString());

      final status = data['status'].toString();
      final debug = data['debug'].toString();
      final debug2 = data['debug2'].toString();
      final debug3 = data['debug3'].toString();
      final msg = data['msg'].toString();

      print("debug : " + debug);
      print("debug2 : " + debug2);
      print("debug3 : " + debug3);

      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      EasyLoading.dismiss();

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: (widget.title != "") ? widget.title : "ติดตามเรื่องร้องเรียน",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("วันที่แจ้ง")),
                            Expanded(child: Text(create_date)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("ชื่อ-สกุล")),
                            Expanded(child: Text(name)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("เรื่อง")),
                            Expanded(child: Text(subject)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //สถานที่เกิดเหตุใกล้เคียง
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("สถานที่เกิดเหตุใกล้เคียง")),
                            Expanded(child: Text(near_location)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //แผนที่
                if (latitude != "")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 32),
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: GoogleMap(
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(latitude),
                                  double.parse(longtitude)),
                              zoom: 18,
                            ),
                            key: ValueKey('uniqueey'),
                            onMapCreated: _onMapCreated,
                            markers: {
                              Marker(
                                  markerId: MarkerId('anyUniqueId'),
                                  position: LatLng(double.parse(latitude),
                                      double.parse(longtitude)),
                                  infoWindow:
                                      InfoWindow(title: 'Some Location'))
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF8C1F78)),
                            ),
                            onPressed: () {
                              var urlMap =
                                  "https://www.google.com/maps/dir/?api=1&destination=" +
                                      latitude.toString() +
                                      "," +
                                      longtitude.toString();
                              _launchInBrowser(urlMap);
                            },
                            child: Text('นำทาง'),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูป
                if (imgcount > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("เบอร์โทรศัพท์ติดต่อ")),
                            Expanded(child: Text(phone)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text("รายละเอียด"),
                              width: MediaQuery.of(context).size.width,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 16),
                              child: Text(description),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //admin
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  color: Color(0xFF8C1F78),
                  child: Text(
                    "สำหรับเจ้าหน้าที่",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                //type
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text("ประเภทของการแจ้งเรื่องร้องเรียน")),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: dropDownCate(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
                //status
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text("สถานะการแจ้งเรื่องร้องเรียน")),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: dropDownCate2(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //admin_reply
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("รายละเอียดการดำเนินการ")),
                          ],
                        ),
                      ),
                      Container(
                        child: TextField(
                          controller: _replyByAdmin,
                          maxLines: 5,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //reply_finish
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  Text("รายละเอียดการดำเนินการเรียบร้อยแล้ว"),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: TextField(
                          controller: _replyFinish,
                          maxLines: 5,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //รูปตอบกลับ
                if (imgcount2 > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพตอบกลับ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount2; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList2[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList2[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูปก่อน
                if (imgcount3 > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพก่อนการดำเนินการ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount3; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList3[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList3[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูปหลัง
                if (imgcount4 > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพหลังการดำเนินการ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount4; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList4[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList4[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูปก่อนอัพ
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("รูปภาพก่อนดำเนินการ")),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xFF8C1F78)),
                                ),
                                onPressed: () {
                                  _openFileImagesExplorer();
                                },
                                child: Text("อัพโหลดรูป"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_images != null || _images != null)
                        SizedBox(
                          height: 120.0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFDFDFDF),
                                ),
                              ),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length,
                              padding: const EdgeInsets.all(2.0),
                              itemBuilder: (context, index) {
                                var filePath =
                                    _images.values.toList()[index].toString();
                                var fileName = _images.values
                                    .toList()[index]
                                    .split('/')
                                    .last
                                    .toString();
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        width: 104.0,
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6.0),
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.grey[300],
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Image.file(
                                                  File(_images.values
                                                      .toList()[index]),
                                                  fit: BoxFit.cover,
                                                  width: 104.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              fileName,
                                              maxLines: 1,
                                              textScaleFactor: 1.0,
                                              style: TextStyle(fontSize: 11.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: -10,
                                        right: -10,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _images.removeWhere(
                                                  (key, value) =>
                                                      value == filePath);
                                              filesImageTotal = _images.length;
                                              fileAllTotal = filesImageTotal;
                                              if (filesImageTotal == 0) {
                                                _images = null;
                                              }
                                            });
                                          },
                                          icon: Icon(Icons.cancel),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Divider(),
                    ],
                  ),
                ),

                //รูปหลังอัพ
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("รูปภาพหลังดำเนินการ")),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xFF8C1F78)),
                                ),
                                onPressed: () {
                                  _openFileImagesExplorer2();
                                },
                                child: Text("อัพโหลดรูป"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_images2 != null || _images2 != null)
                        SizedBox(
                          height: 120.0,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFDFDFDF),
                                ),
                              ),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images2.length,
                              padding: const EdgeInsets.all(2.0),
                              itemBuilder: (context, index) {
                                var filePath =
                                    _images2.values.toList()[index].toString();
                                var fileName = _images2.values
                                    .toList()[index]
                                    .split('/')
                                    .last
                                    .toString();
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        width: 104.0,
                                        child: Column(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6.0),
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.grey[300],
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Image.file(
                                                  File(_images2.values
                                                      .toList()[index]),
                                                  fit: BoxFit.cover,
                                                  width: 104.0,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              fileName,
                                              maxLines: 1,
                                              textScaleFactor: 1.0,
                                              style: TextStyle(fontSize: 11.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: -10,
                                        right: -10,
                                        child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _images2.removeWhere(
                                                  (key, value) =>
                                                      value == filePath);
                                              filesImageTotal2 =
                                                  _images2.length;
                                              fileAllTotal2 = filesImageTotal2;
                                              if (filesImageTotal2 == 0) {
                                                _images2 = null;
                                              }
                                            });
                                          },
                                          icon: Icon(Icons.cancel),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Divider(),
                    ],
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF8C1F78)),
                    ),
                    onPressed: () {
                      updateComplain();
                    },
                    child: Text("อัพเดท"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
