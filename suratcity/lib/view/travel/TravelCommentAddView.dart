import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
var fileList;

class TravelCommentAddView extends StatefulWidget {
  TravelCommentAddView({Key key, this.topicID}) : super(key: key);
  final String topicID;

  @override
  _TravelCommentAddViewState createState() => _TravelCommentAddViewState();
}

class _TravelCommentAddViewState extends State<TravelCommentAddView> {
  var user = User();
  bool isLogin = false;

  final _detail = TextEditingController();
  final _name = TextEditingController();
  bool _validateDetail = false;
  bool _validateName = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
      _name.text = user.fullname;
    });
  }

  insertData() async {
    Map _map = {};
    _map.addAll({
      "description": _detail.text,
      "name": _name.text,
      "tid": widget.topicID,
      "uid": user.uid,
    });
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postData(http.Client(), body, _map);
  }

  Future<List<AllList>> postData(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().commentAdd),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    data = json.decode(response.body);
    EasyLoading.dismiss();
    var status = data['status'].toString();
    var msg = data['msg'].toString();
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "เพิ่มความคิดเห็น",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                //Text(widget.topicID),
                Container(
                  height: 5 * 24.0,
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
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _name,
                    decoration: new InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'ชื่อ',
                      errorText: _validateName ? 'กรุณากรอกชื่อ' : null,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16),
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detail.text.isEmpty
                            ? _validateDetail = true
                            : _validateDetail = false;
                        _name.text.isEmpty
                            ? _validateName = true
                            : _validateName = false;
                        if (!_validateDetail && !_validateName) {
                          EasyLoading.show(status: 'loading...');
                          insertData();
                        }
                      });
                    },
                    child: Text("ส่ง"),
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
