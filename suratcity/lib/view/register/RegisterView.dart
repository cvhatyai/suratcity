import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/register/RegisterOtpView.dart';
import 'package:toast/toast.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';

class RegisterView extends StatefulWidget {
  RegisterView(
      {Key key,
      this.isHaveArrow,
      this.socialID = "",
      this.type = "",
      this.appleFullname = ""})
      : super(key: key);
  final String isHaveArrow;
  final String socialID;
  final String type;
  final String appleFullname;

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _username = TextEditingController();
  final _password1 = TextEditingController();
  final _password2 = TextEditingController();
  final _name = TextEditingController();
  bool _validateUsername = false;
  bool _validatePassword1 = false;
  bool _validatePassword2 = false;
  bool _validateName = false;

  bool isEnable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.appleFullname != "") {
      _name.text = widget.appleFullname;
      setState(() {
        isEnable = false;
      });
    }
  }

  //checkhavephone
  checkUserPhone() async {
    Map _map = {};
    _map.addAll({
      "username": _username.text,
    });
    print("_map_map" + _map.toString());
    var body = json.encode(_map);
    return postCheckUserPhone(http.Client(), body, _map);
  }

  Future<List<AllList>> postCheckUserPhone(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkUserPhone),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();

    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    EasyLoading.dismiss();

    if (status == "success") {
      setOtp();
    } else {
      _showMyDialog(msg);
    }
  }

  setOtp() async {
    Map _map = {};
    _map.addAll({
      "telephone": _username.text,
    });
    print("_map_map" + _map.toString());
    var body = json.encode(_map);
    return postSetOtp(http.Client(), body, _map);
  }

  Future<List<AllList>> postSetOtp(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().setOtp),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    if (status == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterOtpView(
            isHaveArrow: "1",
            username: _username.text,
            password: _password1.text,
            name: _name.text,
            socialID: widget.socialID,
          ),
        ),
      );
    }
  }

  //alert
  Future<void> _showMyDialog(msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap but
      // ton!
      builder: (BuildContext contextSub) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  msg,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(contextSub).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "สมัครสมาชิก",
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
                //username
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _username,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'เบอร์โทรศัพท์ติดต่อ',
                      errorText: _validateUsername
                          ? 'กรุณากรอกเบอร์โทรศัพท์ติดต่อ'
                          : null,
                    ),
                  ),
                ),
                //pass1
                if (widget.socialID == "")
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
                        hintText: 'รหัสผ่าน',
                        errorText:
                            _validatePassword1 ? 'กรุณากรอกรหัสผ่าน' : null,
                      ),
                    ),
                  ),
                //pass2
                if (widget.socialID == "")
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
                        hintText: 'ยืนยันรหัสผ่าน',
                        errorText:
                            _validatePassword2 ? 'กรุณากรอกรหัสผ่าน' : null,
                      ),
                    ),
                  ),
                //fullname
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _name,
                    enabled: isEnable,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'ชื่อ-สกุล',
                      errorText: _validateName ? 'กรุณากรอกชื่อ-สกุล' : null,
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
                      if (widget.socialID == "") {
                        setState(() {
                          _username.text.isEmpty
                              ? _validateUsername = true
                              : _validateUsername = false;
                          _password1.text.isEmpty
                              ? _validatePassword1 = true
                              : _validatePassword1 = false;
                          _password2.text.isEmpty
                              ? _validatePassword2 = true
                              : _validatePassword2 = false;
                          _name.text.isEmpty
                              ? _validateName = true
                              : _validateName = false;
                          if (!_validateUsername &&
                              !_validatePassword1 &&
                              !_validatePassword2 &&
                              !_validateName) {
                            if (_password1.text == _password2.text) {
                              EasyLoading.show(status: 'loading...');
                              checkUserPhone();
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
                      } else {
                        setState(() {
                          _username.text.isEmpty
                              ? _validateUsername = true
                              : _validateUsername = false;
                          _name.text.isEmpty
                              ? _validateName = true
                              : _validateName = false;
                          if (!_validateUsername && !_validateName) {
                            EasyLoading.show(status: 'loading...');
                            checkUserPhone();
                          }
                        });
                      }
                    },
                    child: Text("ยืนยันข้อมูล"),
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
