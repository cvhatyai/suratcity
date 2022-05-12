import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:toast/toast.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';

class RePasswordView extends StatefulWidget {
  RePasswordView({Key key, this.isHaveArrow, this.telephone}) : super(key: key);
  final String isHaveArrow;
  final String telephone;

  @override
  _RePasswordViewState createState() => _RePasswordViewState();
}

class _RePasswordViewState extends State<RePasswordView> {
  final _password1 = TextEditingController();
  final _password2 = TextEditingController();
  bool _validatePassword1 = false;
  bool _validatePassword2 = false;

  //checkHavePhone
  changePasswordOtp() async {
    Map _map = {};
    _map.addAll({
      "telephone": widget.telephone,
      "password": _password1.text,
    });
    print("_map_map" + _map.toString());
    var body = json.encode(_map);
    return postChangePasswordOtp(http.Client(), body, _map);
  }

  Future<List<AllList>> postChangePasswordOtp(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().changePasswordOtp),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();

    if (status == "success") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FrontPageView()),
        ModalRoute.withName("/"),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FrontPageView()),
        ModalRoute.withName("/"),
      );
    }
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ลืมรหัสผ่าน",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: [
                //pass1
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _password1,
                    obscureText: true,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'รหัสผ่านใหม่',
                      errorText:
                          _validatePassword1 ? 'กรุณากรอกรหัสผ่านใหม่' : null,
                    ),
                  ),
                ),
                //pass2
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _password2,
                    obscureText: true,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'ยืนยันรหัสผ่านใหม่',
                      errorText:
                          _validatePassword2 ? 'กรุณากรอกรหัสผ่านใหม่' : null,
                    ),
                  ),
                ),
                //btnLogin
                Container(
                  margin: EdgeInsets.only(top: 16),
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF8C1F78)),
                    ),
                    onPressed: () {
                      setState(() {
                        _password1.text.isEmpty
                            ? _validatePassword1 = true
                            : _validatePassword1 = false;
                        _password2.text.isEmpty
                            ? _validatePassword2 = true
                            : _validatePassword2 = false;
                        if (!_validatePassword1 && !_validatePassword2) {
                          if (_password1.text == _password2.text) {
                            EasyLoading.show(status: 'loading...');
                            changePasswordOtp();
                          } else {
                            if (FocusScope.of(context).isFirstFocus) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            }
                            Toast.show("กรุณากรอกรหัสผ่านให้ตรงกัน", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          }
                        }
                      });
                    },
                    child: Text("ยืนยันเปลี่ยนรหัสผ่าน"),
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
