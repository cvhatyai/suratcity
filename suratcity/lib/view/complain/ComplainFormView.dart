import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:place_picker/place_picker.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';
import 'FollowComplainListView.dart';

var data;

Map<String, String> _images;
List<File> _filesImage = List<File>();
Map<String, String> _files;
List<File> _filesAny = List<File>();
int fileAllTotal = 0;
Map<String, String> _dataFiles;
List<File> _filesAll = List<File>();

typedef void OnPickImageCallback(
    double maxWidth, double maxHeight, int quality);

class ComplainFormView extends StatefulWidget {
  ComplainFormView(
      {Key key, this.topicID, this.subjectTitle, this.displayImage})
      : super(key: key);
  final String topicID;
  final String subjectTitle;
  final String displayImage;

  @override
  _ComplainFormViewState createState() => _ComplainFormViewState();
}

class _ComplainFormViewState extends State<ComplainFormView> {
  //setup image files
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  FileType fileType;
  int filesImageTotal = 0;
  var progress;

  //setup file
  String fileAnyName;
  String pathAny;
  Map<String, String> pathsAny;
  List<String> extensionsAny;
  bool isLoadingPathAny = false;
  FileType fileAnyType;
  int filesTotal = 0;
  var progressFiles;

  //setup camera files
  final ImagePicker _picker = ImagePicker();
  PickedFile _imageFile;
  dynamic _pickImageError;

  //location
  var location = "";
  String Lat = "";
  String Lng = "";

  var userFullname;
  var uid;

  final _subject = TextEditingController();
  final _detail = TextEditingController();
  final _place = TextEditingController();
  bool _validateSubject = false;
  bool _validateDetail = false;
  bool _validatePlace = false;

  var user = User();
  bool isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _clearUiView();
    getUsers();
  }

  void _clearUiView() {
    setState(() {
      _images = null;
      _files = null;
    });
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
    });
  }

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  //ส่งข้อมูล

  insertDataTest() {
    EasyLoading.dismiss();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => new CupertinoAlertDialog(
        title: Text(
            "ระบบได้ส่งเรื่องร้องเรียนของท่านไปยังเจ้าหน้าที่เรียบร้อยแล้ว"),
        content: RichText(
          text: TextSpan(
            /*  text:
                "ระบบได้ส่งเรื่องร้องเรียนของท่านไปยังเจ้าหน้าที่เรียบร้อยแล้ว",
            style: TextStyle(color: Colors.black, fontSize: 18),*/
            children: [
              TextSpan(
                text:
                    "ท่านสามารถตรวจสอบเรื่องร้องเรียนได้ที่ เมนู ติดตามเรื่องร้องเรียน หรือ ",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextSpan(
                text: "คลิ๊กที่นี่",
                style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pop(context);
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }

  insertData() async {
    _filesAll.clear();

    if (_images != null && _files != null) {
      _dataFiles = {
        ..._images,
        ..._files,
      };
    } else if (_images != null && _files == null) {
      _dataFiles = _images;
    } else if (_files != null && _images == null) {
      _dataFiles = _files;
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

    var uri = Uri.parse(Info().informAdd);
    var request = http.MultipartRequest('POST', uri);

    var platform = "";
    if (Platform.isAndroid) {
      platform = "android";
    } else {
      platform = "ios";
    }

    request.fields['subject'] = _subject.text;
    request.fields['detail'] = _detail.text;
    request.fields['near_location'] = _place.text;
    request.fields['type_id'] = widget.topicID.toString();
    request.fields['uid'] = user.uid;
    request.fields['name'] = "อนุสรณ์ คงทอง";
    request.fields['latitude'] = Lat;
    request.fields['longtitude'] = Lng;
    request.fields['platform'] = platform;

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

    print("wit before submit");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("wit after submit");
    if (response.statusCode == 200) {
      EasyLoading.dismiss();
      final data = jsonDecode(response.body);
      print('wit data: ' + data.toString());

      final status = data['status'].toString();
      final msg = data['msg'].toString();
      if (status == 'success') {
        EasyLoading.dismiss();

        /*Toast.show("ส่งข้อมูลเรียบร้อยแล้ว", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FollowComplainListView(
              isHaveArrow: "1",
              title: "ตรวจสอบเรื่องร้องเรียน",
            ),
          ),
        );
        */

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            title: Text(
                "ระบบได้ส่งเรื่องร้องเรียนของท่านไปยังเจ้าหน้าที่เรียบร้อยแล้ว"),
            content: RichText(
              text: TextSpan(
                /*  text:
                "ระบบได้ส่งเรื่องร้องเรียนของท่านไปยังเจ้าหน้าที่เรียบร้อยแล้ว",
            style: TextStyle(color: Colors.black, fontSize: 18),*/
                children: [
                  TextSpan(
                    text:
                        "ท่านสามารถตรวจสอบเรื่องร้องเรียนได้ที่ เมนู ติดตามเรื่องร้องเรียน หรือ ",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  TextSpan(
                    text: "คลิ๊กที่นี่",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 18),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowComplainListView(
                              isHaveArrow: "1",
                              title: "ตรวจสอบเรื่องร้องเรียน",
                            ),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => new CupertinoAlertDialog(
            title: new Text(
              "ขออภัยค่ะ",
              textScaleFactor: 1.0,
              style: TextStyle(color: Colors.red),
            ),
            content: new Text(
              msg,
              textScaleFactor: 1.0,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'ตกลง',
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        );
      }
    }
  }

  //เปิดภาพ
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
        fileAllTotal = filesImageTotal + filesTotal;
      }
    });
  }

  //เปิดไฟล์
  void _openFilesExplorer() async {
    extensionsAny = ['docx', 'pdf', 'pages'];
    setState(() => isLoadingPathAny = true);
    try {
      pathAny = null;
      pathsAny = await FilePicker.getMultiFilePath(
          type: fileAnyType != null ? fileAnyType : FileType.custom,
          allowedExtensions: extensionsAny);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPathAny = false;
      fileAnyName = pathAny != null
          ? pathAny.split('/').last
          : pathsAny != null
              ? pathsAny.keys.toString()
              : '...';
      if (pathsAny != null) {
        if (_files != null) {
          for (var i = 0; i < pathsAny.length; i++) {
            var keys = pathsAny.keys.toList()[i].toString();
            var values = pathsAny.values.toList()[i].toString();
            _files[keys] = values;
          }
        } else {
          _files = pathsAny;
        }
        filesTotal = _files.length;
        fileAllTotal = filesTotal + filesImageTotal;
      }
    });
  }

  //เปิดกล้อง
  void _openCameraExplorer(ImageSource source, {BuildContext context}) async {
    await _displayPickImageDialog(context,
        (double maxWidth, double maxHeight, int quality) async {
      try {
        final pickedFile = await _picker.getImage(
          source: source,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: quality,
        );
        setState(() {
          _imageFile = pickedFile;
          var path = _imageFile.path;
          var name = _imageFile.path.split('/').last.toString();
          //print("camera: $name : $path");
          if (_images != null) {
            var keys = name;
            var values = path;
            _images[keys] = values;
          } else {
            _images = {name: path};
          }

          print('wit img camera: ${_images}');
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    });
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  //แผนที่
  void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              PlacePicker("AIzaSyB91yhHGMRWDgLYajpg8ACtG5Dl1YUFFEw")),
    );
    // Handle the result in your way
    print("result" + result.toString());
    print(result.latLng.toString());
    print(result.latLng.latitude.toString());
    if (result != null) {
      Lat = result.latLng.latitude.toString();
      Lng = result.latLng.longitude.toString();
      setState(() {
        location = result.latLng.latitude.toString() +
            " " +
            result.latLng.longitude.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "แจ้งเรื่องร้องเรียน",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Column(
              children: [
                //header
                Row(
                  children: [
                    Image.network(
                      widget.displayImage,
                      height: 36,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          widget.subjectTitle,
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //หัวข้อ
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _subject,
                    decoration: new InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'หัวข้อ',
                      errorText: _validateSubject ? 'กรุณากรอกหัวข้อ' : null,
                    ),
                  ),
                ),

                //รายละเอียด
                Container(
                  height: 5 * 24.0,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _detail,
                    maxLines: 5,
                    decoration: new InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'รายละเอียด',
                      errorText: _validateDetail ? 'กรุณากรอกรายละเอียด' : null,
                    ),
                  ),
                ),

                //สถานที่
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _place,
                    decoration: new InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'สถานที่',
                      errorText: _validatePlace ? 'กรุณากรอกสถานที่' : null,
                    ),
                  ),
                ),

                //หรือปักหมุดจากแผนที่
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF65A5D8)),
                  ),
                  onPressed: () {
                    showPlacePicker();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_pin),
                        Container(
                          child: Text("หรือปักหมุดจากแผนที่"),
                          margin: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                //location
                if (location != "")
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(9.0),
                      ),
                      color: Color(0xFFb2d5f1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              location,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                location = "";
                                Lat = "";
                                Lng = "";
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                //แนบไฟล์หลักฐาน
                Container(
                  margin: EdgeInsets.only(top: 16),
                  alignment: Alignment.centerLeft,
                  child: Text("แนบไฟล์หลักฐาน"),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _openFileImagesExplorer();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF65A5D8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "รูปภาพ/วีดีโอ",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _openCameraExplorer(ImageSource.camera,
                                context: context);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF65A5D8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "กล้อง",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _openFilesExplorer();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF65A5D8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.file_present,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "เอกสาร",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6.0),
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300],
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Image.file(
                                            File(
                                                _images.values.toList()[index]),
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
                                            (key, value) => value == filePath);
                                        filesImageTotal = _images.length;
                                        fileAllTotal =
                                            filesTotal + filesImageTotal;
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

                if (_files != null || _files != null)
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
                        itemCount: _files.length,
                        padding: const EdgeInsets.all(2.0),
                        itemBuilder: (context, index) {
                          var filePath =
                              _files.values.toList()[index].toString();
                          var fileName = _files.values
                              .toList()[index]
                              .split('/')
                              .last
                              .toString();
                          var extensions = fileName.split('.').last.toString();
                          //print(extensions);
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
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(6.0),
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300],
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Image(
                                              image: AssetImage(
                                                  "assets/images/$extensions.png"),
                                              width: 80.0,
                                            ),
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
                                        _files.removeWhere(
                                            (key, value) => value == filePath);
                                        filesTotal = _files.length;
                                        fileAllTotal =
                                            filesTotal + filesImageTotal;
                                        if (filesTotal == 0) {
                                          _files = null;
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

                //sendData
                Container(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detail.text.isEmpty
                            ? _validateDetail = true
                            : _validateDetail = false;
                        _subject.text.isEmpty
                            ? _validateSubject = true
                            : _validateSubject = false;
                        _place.text.isEmpty
                            ? _validatePlace = true
                            : _validatePlace = false;

                        if (!_validateDetail &&
                            !_validateSubject &&
                            !_validatePlace) {
                          EasyLoading.show(status: 'loading...');
                          insertData();
                        }
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFFFA143)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("ส่งเรื่องร้องเรียน"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
