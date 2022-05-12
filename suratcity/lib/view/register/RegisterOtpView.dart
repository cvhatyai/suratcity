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

class RegisterOtpView extends StatefulWidget {
  RegisterOtpView(
      {Key key,
      this.isHaveArrow,
      this.username,
      this.password,
      this.name,
      this.socialID})
      : super(key: key);
  final String isHaveArrow;
  final String username;
  final String password;
  final String name;
  final String socialID;

  @override
  _RegisterOtpViewState createState() => _RegisterOtpViewState();
}

class _RegisterOtpViewState extends State<RegisterOtpView> {
  final _otp = TextEditingController();
  bool _validateOTP = false;

  var user = User();

  //checkHavePhone
  checkOtp() async {
    Map _map = {};
    _map.addAll({
      "telephone": widget.username,
      "otp": _otp.text,
    });
    var body = json.encode(_map);
    return postCheckOtp(http.Client(), body, _map);
  }

  Future<List<AllList>> postCheckOtp(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkOtp),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();

    if (status == "success") {
      userRegistAdd();
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }

    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    EasyLoading.dismiss();
  }

  //userRegistAdd
  userRegistAdd() async {
    Map _map = {};
    _map.addAll({
      "username": widget.username,
      "password": widget.password,
      "name": widget.name,
      "socialID": widget.socialID,
    });
    print("_map_map" + _map.toString());
    var body = json.encode(_map);
    return postUserRegistAdd(http.Client(), body, _map);
  }

  Future<List<AllList>> postUserRegistAdd(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().userRegistAdd),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    if (status == "success") {
      await user.init();
      user.isLogin = true;
      user.uid = rs["uid"].toString();
      user.fullname = rs["fullname"].toString();
      user.phone = rs["phone"].toString();
      user.avatar = rs["avatar"].toString();
      user.email = rs["email"].toString();
      user.priv = rs["priv"].toString();
      user.username = rs["username"].toString();
      user.password = rs["password"].toString();
      user.citizen_id = rs["citizen_id"].toString();
      user.authen_token = rs["authen_token"].toString();
      user.userclass = rs["userclass"].toString();

      user.facebook_id = rs["facebook_id"].toString();
      user.line_id = rs["line_id"].toString();
      user.google_id = rs["google_id"].toString();
      user.apple_id = rs["apple_id"].toString();

      user.isNoti = "1";

      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FrontPageView()),
        ModalRoute.withName("/"),
      );
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }

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
                //title
                Container(
                  child: Text(
                    "ระบุรหัส OTP ที่ได้รับจาก SMS",
                    textAlign: TextAlign.center,
                  ),
                ),
                //username
                Container(
                  height: 50,
                  margin: EdgeInsets.only(top: 16),
                  child: TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'กรอกรหัส OTP',
                      errorText: _validateOTP ? 'กรุณากรอกรหัส OTP' : null,
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
                        _otp.text.isEmpty
                            ? _validateOTP = true
                            : _validateOTP = false;
                        if (!_validateOTP) {
                          EasyLoading.show(status: 'loading...');
                          checkOtp();
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
