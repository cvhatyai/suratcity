import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:toast/toast.dart';

import '../AppBarView.dart';

var data;

class PhoneEditView extends StatefulWidget {
  PhoneEditView(
      {Key key, this.isHaveArrow = "", this.id = "", this.subject = ""})
      : super(key: key);
  final String isHaveArrow;
  final String id;
  final String subject;

  @override
  _PhoneEditViewState createState() => _PhoneEditViewState();
}

class _PhoneEditViewState extends State<PhoneEditView> {
  final _fullname = TextEditingController();
  final _detail = TextEditingController();
  bool _validateFullname = false;
  bool _validateDetail = false;

  insertData() {
    Map _map = {};
    _map.addAll({
      "id": widget.id,
      "subject": _fullname.text,
      "detail": _detail.text,
    });
    var body = json.encode(_map);
    return postContactData(http.Client(), body, _map);
  }

  Future<List<AllList>> postContactData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().callEdit),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    data = json.decode(response.body);
    print("data" + data.toString());
    var status = data['status'].toString();
    if (status == "success") {
      Toast.show(data['msg'].toString(), context,
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
          title: "แจ้งแก้ไขข้อมูล",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 8, right: 16, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "แจ้งแก้ไขข้อมูลของ " + widget.subject,
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: TextField(
                      controller: _fullname,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(
                          left: 12,
                          right: 1,
                          top: 1,
                          bottom: 1,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        hintText: 'ชื่อ-นามสกุล ผู้แจ้งแก้ไข',
                        errorText: _validateFullname
                            ? 'กรุณากรอกชื่อ-นามสกุล ผู้แจ้งแก้ไข'
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    height: 8 * 24.0,
                    child: TextField(
                      controller: _detail,
                      maxLines: 8,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        hintText: 'กรอกรายละเอียด...',
                        errorText:
                            _validateDetail ? 'กรุณากรอกรายละเอียด' : null,
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
                          _fullname.text.isEmpty
                              ? _validateFullname = true
                              : _validateFullname = false;
                          if (!_validateDetail && !_validateFullname) {
                            EasyLoading.show(status: 'loading...');
                            insertData();
                          }
                        });
                      },
                      child: Container(
                        child: Text("เสร็จสิ้น"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
