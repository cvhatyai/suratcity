import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http_parser/http_parser.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:share/share.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

var data;

Map<String, String> _images;
int fileAllTotal = 0;

Map<String, String> _dataFiles;
List<File> _filesAll = List<File>();

//dropdown
var arrMap;
Map<int, String> dataCateMap = {0: "-- หมวดสินค้า --"};
//dropdown

class GreenMarketAddView extends StatefulWidget {
  GreenMarketAddView({Key key, this.topicID, this.isHaveArrow})
      : super(key: key);
  final String topicID;
  final String isHaveArrow;

  @override
  _GreenMarketAddViewState createState() => _GreenMarketAddViewState();
}

class _GreenMarketAddViewState extends State<GreenMarketAddView> {
  var user = User();

  //location
  var location = "";
  String Lat = "";
  String Lng = "";

  //setup image files
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  FileType fileType;
  int filesImageTotal = 0;

  //setup image files add more
  List<dynamic> _imagesTmp = [];
  List<int> fileAllTotalTmp = [];
  List<int> filesImageTotalTmp = [];

  List<String> fileNameTmp = [];
  List<String> pathTmp = [];
  List<dynamic> pathsTmp = [];
  List<dynamic> extensionsTmp = [];
  List<dynamic> fileTypeTmp = [];

  List<dynamic> _dataFilesTmp = [];
  List<dynamic> _filesAllTmp = [];

  final _shopName = TextEditingController();
  final _shopAddress = TextEditingController();
  final _shopPhone = TextEditingController();
  final _shopLine = TextEditingController();
  final _shopTime = TextEditingController();

  /*final _productName = TextEditingController();
  final _productDetail = TextEditingController();*/

  List<TextEditingController> _productName = [
    for (int i = 0; i < 150; i++) TextEditingController()
  ];
  List<TextEditingController> _productDetail = [
    for (int i = 0; i < 150; i++) TextEditingController()
  ];

  List<FocusNode> _focusNode = [for (int i = 0; i < 150; i++) FocusNode()];

  bool _validateShop = false;
  bool _validateAddress = false;
  bool _validatePhone = false;
  bool _validateLine = false;
  bool _validateTime = false;

  /*bool _validateProductName = false;
  bool _validateProductDetail = false;*/

  List<bool> _validateProductName = [for (int i = 0; i < 150; i++) false];
  List<bool> _validateProductDetail = [for (int i = 0; i < 150; i++) false];

  List<int> product = [];
  List<String> dropdownValue2 = [];
  List<String> cateVal = [];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
  }

  @override
  void dispose() {
    super.dispose();
    /*   if (_images != null) {
      _images = null;
    }

    if (_dataFiles != null) {
      _dataFiles = null;
    }*/

    product.clear();
  }

  getUsers() async {
    await user.init();
    getShopDetail();
    addProductMore();
  }

  getShopDetail() async {
    Map _map = {};
    _map.addAll({
      "uid": user.uid != "" ? user.uid : "2",
    });
    var body = json.encode(_map);
    return postShopDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postShopDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().getShopDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      _shopName.text = rs['shopName'].toString();
      _shopAddress.text = rs['shopAddress'].toString();
      _shopPhone.text = rs['shopPhone'].toString();
      _shopLine.text = rs['shopLine'].toString();
      _shopTime.text = rs['shopTime'].toString();
    });
    if (rs['lat'].toString() != "") {
      Lat = rs['lat'].toString();
      Lng = rs['lng'].toString();
      updateMarker();
    }
  }

  //เพิ่มสินค้า
  addProductMore() {
    int productIndex = (product.length == 0) ? 1 : product.length + 1;
    product.add(productIndex);
    cateVal.add("0");
    dropdownValue2.add("0");

    _imagesTmp.add(_images);
    fileAllTotalTmp.add(0);
    filesImageTotalTmp.add(0);

    fileNameTmp.add(fileName);
    pathTmp.add(path);
    pathsTmp.add(paths);
    extensionsTmp.add(extensions);
    fileTypeTmp.add(fileType);

    _dataFilesTmp.add(_dataFiles);
    _filesAllTmp.add(_filesAll);

    getCateList();
    setState(() {});

    if (productIndex != 1) {
      Timer(
        Duration(milliseconds: 100),
        () => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
      );
    }
  }

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "market",
    });
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateListPity),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCateData(response.body);
  }

  List<AllList> parseCateData(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMap = parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    Map<int, String> tmpDataCateMap;
    tmpDataCateMap =
        Map.fromIterable(arrMap, key: (e) => e.id, value: (e) => e.cate_name);
    dataCateMap.addAll(tmpDataCateMap);
    setState(() {});
    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  Widget dropDownCate(i) {
    return (arrMap != null && arrMap.length != 0)
        ? Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: dropdownValue2[i],
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF333333),
                    ),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Color(0xFF333333)),
                    underline: Container(
                      height: 1,
                      color: Colors.transparent,
                    ),
                    onChanged: (String newValue) {
                      Timer(Duration(milliseconds: 100), () {
                        if (FocusScope.of(context).isFirstFocus) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        }
                      });

                      setState(() {
                        dropdownValue2[i] = newValue;
                        print("dropDownCate aaa : " + cateVal.toString());
                        cateVal[i] = dropdownValue2[i];
                        print("dropDownCate bbb : " + cateVal.toString());
                      });
                    },
                    items: dataCateMap.entries
                        .map<DropdownMenuItem<String>>(
                            (MapEntry<int, String> e) =>
                                DropdownMenuItem<String>(
                                  value: e.key.toString(),
                                  child: Text(
                                    e.value,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ))
                        .toList(),
                  ),
                ),
                Positioned(
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: Text(
                      "หมวดสินค้า",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C1F78)),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  checkInput() {
    bool isCanInsert = false;
    List<bool> isCanInsertArr = [];

    bool isCanInsert2 = false;
    List<bool> isCanInsertArr2 = [];

    setState(() {
      _shopName.text.isEmpty ? _validateShop = true : _validateShop = false;
      _shopAddress.text.isEmpty
          ? _validateAddress = true
          : _validateAddress = false;
      _shopPhone.text.isEmpty ? _validatePhone = true : _validatePhone = false;
      _shopLine.text.isEmpty ? _validateLine = true : _validateLine = false;
      _shopTime.text.isEmpty ? _validateTime = true : _validateTime = false;

      for (int i = 0; i < product.length; i++) {
        _productName[i].text.isEmpty
            ? _validateProductName[i] = true
            : _validateProductName[i] = false;
        _validateProductName[i] == false
            ? isCanInsert = true
            : isCanInsert = false;
        _productDetail[i].text.isEmpty
            ? _validateProductDetail[i] = true
            : _validateProductDetail[i] = false;
        _validateProductDetail[i] == false
            ? isCanInsert = true
            : isCanInsert = false;
        isCanInsertArr.add(isCanInsert);
        cateVal[i] == "0" ? isCanInsert2 = false : isCanInsert2 = true;
        isCanInsertArr2.add(isCanInsert2);
      }
    });

    if (!isCanInsertArr.contains(false)) {
      if (!isCanInsertArr2.contains(false)) {
        if (isCanInsert) {
          if (!_validateShop &&
              !_validateAddress &&
              !_validatePhone &&
              !_validateTime) {
            EasyLoading.show(status: 'loading...');
            insertDataAll();
          }
        }
      } else {
        Toast.show("กรุณาเลือกหมวด", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
  }

  insertDataAll() async {
    for (int i = 0; i < product.length; i++) {
      await insertData(i);
    }
  }

  insertData(i) async {
    _filesAllTmp[i].clear();

    print("_imagesTmp $i : " + _imagesTmp[i].toString());
    if (_imagesTmp[i] != null) {
      _dataFilesTmp[i] = _imagesTmp[i];

      //_dataFilesTmp[i].add(_imagesTmp[i]);
    }

    print("_dataFilesTmp $i : " + _dataFilesTmp[i].toString());

    if (_dataFilesTmp[i] != null) {
      for (int j = 0; j < _dataFilesTmp[i].length; j++) {
        var file = await getImageFileFromAsset(
            _dataFilesTmp[i].values.toList()[j].toString());
        setState(() {
          _filesAllTmp[i].add(file);
        });
      }
    }

    var uri = Uri.parse(Info().insertMarketAndProduct);
    var request = http.MultipartRequest('POST', uri);

    request.fields['shopName'] = _shopName.text;
    request.fields['shopAddress'] = _shopAddress.text;
    request.fields['shopPhone'] = _shopPhone.text;
    request.fields['shopLine'] = _shopLine.text;
    request.fields['shopTime'] = _shopTime.text;

    request.fields['lat'] = Lat;
    request.fields['lng'] = Lng;

    request.fields['productName'] = _productName[i].text;
    request.fields['productCID'] = cateVal[i];
    request.fields['productDetail'] = _productDetail[i].text;
    request.fields['uid'] = user.uid;

    if (_filesAllTmp[i].length > 0) {
      var len_file = _filesAllTmp[i].length;
      //print("wit len file $len_file");
      for (int j = 0; j < len_file; j++) {
        var ext = _filesAllTmp[i][j].path.split('.').last;
        var file = await http.MultipartFile.fromPath(
            'file[$j]', _filesAllTmp[i][j].path,
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

      if (i == product.length - 1) {
        Navigator.pop(context);
      }
    }
  }

  Future<File> getImageFileFromAsset(String path) async {
    final file = File(path);
    return file;
  }

  //เปิดภาพ
  void _openFileImagesExplorer(i) async {
    try {
      pathTmp[i] = null;
      pathsTmp[i] = await FilePicker.getMultiFilePath(
          type: fileTypeTmp[i] != null ? fileTypeTmp[i] : FileType.image,
          allowedExtensions: extensionsTmp[i]);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      fileNameTmp[i] = pathTmp[i] != null
          ? pathTmp[i].split('/').last
          : pathsTmp[i] != null
              ? pathsTmp[i].keys.toString()
              : '...';

      if (pathsTmp[i] != null) {
        if (_imagesTmp[i] != null) {
          for (var i = 0; i < pathsTmp[i].length; i++) {
            var keys = pathsTmp[i].keys.toList()[i].toString();
            var values = pathsTmp[i].values.toList()[i].toString();
            _imagesTmp[i][keys] = values;
          }
        } else {
          _imagesTmp[i] = pathsTmp[i];
        }
        filesImageTotalTmp[i] = _imagesTmp[i].length;
        fileAllTotalTmp[i] = filesImageTotalTmp[i];
      }
    });
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

    print("name : " + result.name.toString());
    print("locality : " + result.locality.toString());
    print("formattedAddress : " + result.formattedAddress.toString());

    if (result != null) {
      setState(() {
        Lat = result.latLng.latitude.toString();
        Lng = result.latLng.longitude.toString();
        _shopAddress.text = result.name.toString();
      });
      updateMarker();
    }
  }

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Marker _marker;

  CameraPosition _camera;

  updateMarker() {
    _marker = Marker(
      markerId: MarkerId('anyUniqueId'),
      position: LatLng(double.parse(Lat), double.parse(Lng)),
      infoWindow: InfoWindow(title: 'Some Location'),
    );

    _camera = CameraPosition(
      target: LatLng(double.parse(Lat), double.parse(Lng)),
      zoom: 16,
    );

    var newPosition = CameraPosition(
        target: LatLng(double.parse(Lat), double.parse(Lng)), zoom: 16);
    CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
    mapController.moveCamera(update);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarView(
        title: "สมัครขายสินค้า",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: EdgeInsets.only(left: 8, right: 8),
          // margin: EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //ชื่อร้าน
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 16),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      margin: EdgeInsets.only(top: 8),
                      child: TextField(
                        controller: _shopName,
                        style: TextStyle(
                          color: Color(0xFF8C1F78),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          errorText: _validateShop ? 'กรุณากรอกชื่อร้าน' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          "ชื่อร้าน",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C1F78)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //ที่อยู่ร้าน
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 8),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: TextField(
                        controller: _shopAddress,
                        style: TextStyle(
                          color: Color(0xFF8C1F78),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          errorText:
                              _validateAddress ? 'กรุณากรอกที่อยู่ร้าน' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          "ที่อยู่ร้าน",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C1F78)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //หรือปักหมุดจากแผนที่
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    showPlacePicker();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFDFF4FF),
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                      border: Border.all(
                        color: Color(0xFF8C1F78),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Wrap(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(
                            0xFFFF0000,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          child: Text(
                            "หรือปักหมุดจากแผนที่",
                            style: TextStyle(
                              color: Color(0xFF8C1F78),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //map
              if (Lat != "")
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  margin: EdgeInsets.only(top: 8),
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: GoogleMap(
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: _camera,
                    key: ValueKey('uniqueey'),
                    onMapCreated: _onMapCreated,
                    markers: {
                      _marker
                      /*Marker(
                            markerId: MarkerId('anyUniqueId'),
                            position: LatLng(double.parse(Lat), double.parse(Lng)),
                            infoWindow: InfoWindow(title: 'Some Location'),
                          ),*/
                    },
                  ),
                ),

              //เบอร์ติดต่อ
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 2),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: TextField(
                        controller: _shopPhone,
                        style: TextStyle(
                          color: Color(0xFF8C1F78),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFF48BE00),
                          ),
                          errorText:
                              _validatePhone ? 'กรุณากรอกเบอร์ติดต่อ' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          "เบอร์ติดต่อ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C1F78)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Line ID
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 2),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: TextField(
                        controller: _shopLine,
                        style: TextStyle(
                          color: Color(0xFF8C1F78),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFF48BE00),
                          ),
                          errorText: _validateLine ? 'กรุณากรอก Line ID' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          "Line ID",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C1F78)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //ที่อยู่ร้าน
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 8),
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: TextField(
                        controller: _shopTime,
                        style: TextStyle(
                          color: Color(0xFF8C1F78),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          errorText:
                              _validateTime ? 'กรุณากรอกเวลาทำการ' : null,
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 0.0),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        color: Colors.white,
                        child: Text(
                          "เวลาทำการ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C1F78)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              for (int i = 0; i < product.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //ชื่อสินค้า
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      margin: EdgeInsets.only(top: 32),
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            child: TextField(
                              controller: _productName[i],
                              style: TextStyle(
                                color: Color(0xFF8C1F78),
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                errorText: _validateProductName[i]
                                    ? 'กรุณากรอกชื่อสินค้า'
                                    : null,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              color: Colors.white,
                              child: Text(
                                "ชื่อสินค้า",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C1F78)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    dropDownCate(i),

                    //รายละเอียดสินค้า
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      margin: EdgeInsets.only(top: 16),
                      height: 5 * 24.0,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            child: TextField(
                              controller: _productDetail[i],
                              style: TextStyle(
                                color: Color(0xFF8C1F78),
                              ),
                              maxLines: 5,
                              decoration: InputDecoration(
                                isDense: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                errorText: _validateProductDetail[i]
                                    ? 'กรุณากรอกรายละเอียดสินค้า'
                                    : null,
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 0.0),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              color: Colors.white,
                              child: Text(
                                "รายละเอียดสินค้า",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8C1F78)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_imagesTmp[i] != null)
                      SizedBox(
                        height: 120.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFDFDFDF),
                              ),
                            ),
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagesTmp[i].length,
                            padding: const EdgeInsets.all(2.0),
                            itemBuilder: (context, index) {
                              var filePath = _imagesTmp[i]
                                  .values
                                  .toList()[index]
                                  .toString();
                              var fileName = _imagesTmp[i]
                                  .values
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
                                                File(_imagesTmp[i]
                                                    .values
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
                                            _imagesTmp[i].removeWhere(
                                                (key, value) =>
                                                    value == filePath);
                                            filesImageTotalTmp[i] =
                                                _imagesTmp[i].length;
                                            fileAllTotalTmp[i] =
                                                filesImageTotalTmp[i];
                                            if (filesImageTotalTmp[i] == 0) {
                                              _imagesTmp[i] = null;
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

                    //แนบรูป
                    GestureDetector(
                      onTap: () {
                        _openFileImagesExplorer(i);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        margin: EdgeInsets.only(top: 12),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8C1F78),
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                            border: Border.all(
                              color: Color(0xFF8C1F78),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Wrap(
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 16,
                                  color: Color(
                                    0xFFFFFFFF,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 8),
                                  child: Text(
                                    "แนบรูปสินค้า",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              //เพิ่มสินค้าถัดไป +
              GestureDetector(
                onTap: () {
                  addProductMore();
                },
                child: Container(
                  height: 32,
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  margin: EdgeInsets.only(top: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF8C1F78),
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                      border: Border.all(
                        color: Color(0xFF8C1F78),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Wrap(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            child: Text(
                              "เพิ่มสินค้าถัดไป",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            size: 16,
                            color: Color(
                              0xFFFFFFFF,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              //สมัครขายสินค้า
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(top: 28, bottom: 28),
                child: GestureDetector(
                  onTap: () {
                    //EasyLoading.show(status: 'loading...');
                    checkInput();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF8C1F78),
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                      border: Border.all(
                        color: Color(0xFF8C1F78),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "สมัครขายสินค้า",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
