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

class ChangePasswordView extends StatefulWidget {
  ChangePasswordView({Key key, this.isHaveArrow}) : super(key: key);
  final String isHaveArrow;

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  var user = User();
  bool isLogin = false;

  final _password1 = TextEditingController();
  final _password2 = TextEditingController();
  final _password3 = TextEditingController();
  bool _validatePassword1 = false;
  bool _validatePassword2 = false;
  bool _validatePassword3 = false;

  var appName = "";

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
    });
  }

  //changePassword
  changePassword() async {
    Map _map = {};
    _map.addAll({
      "password_old": _password1.text,
      "password_new": _password2.text,
      "uid": user.uid,
      "username": user.username,
    });

    print("_map" + _map.toString());
    var body = json.encode(_map);
    return postChangePassword(http.Client(), body, _map);
  }

  Future<List<AllList>> postChangePassword(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().changePassword),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    var passwordNew = rs["password"].toString();

    if (status == "success") {
      user.password = passwordNew;
      Navigator.pop(context);
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
        title: "เปลี่ยนรหัสผ่าน",
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
                //passwordOld
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
                      hintText: 'รหัสผ่านเดิม',
                      errorText:
                          _validatePassword1 ? 'กรุณากรอกรหัสผ่าน' : null,
                    ),
                  ),
                ),

                //passwordNew
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
                      hintText: 'รหัสผ่านใหม่',
                      errorText:
                          _validatePassword2 ? 'กรุณากรอกรหัสผ่าน' : null,
                    ),
                  ),
                ),

                //passwordNew
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _password3,
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
                          _validatePassword3 ? 'กรุณากรอกรหัสผ่าน' : null,
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
                          MaterialStateProperty.all<Color>(Color(0xFF65A5D8)),
                    ),
                    onPressed: () {
                      setState(() {
                        _password1.text.isEmpty
                            ? _validatePassword1 = true
                            : _validatePassword1 = false;
                        _password2.text.isEmpty
                            ? _validatePassword2 = true
                            : _validatePassword2 = false;
                        _password3.text.isEmpty
                            ? _validatePassword3 = true
                            : _validatePassword3 = false;
                        if (!_validatePassword1 &&
                            !_validatePassword2 &&
                            !_validatePassword3) {
                          if (_password2.text != _password3.text) {
                            if (FocusScope.of(context).isFirstFocus) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            }
                            Toast.show("รหัสผ่านไม่ตรงกัน", context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          } else {
                            EasyLoading.show(status: 'loading...');
                            changePassword();
                          }
                        }
                      });
                    },
                    child: Text("ดำเนินการต่อ"),
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
