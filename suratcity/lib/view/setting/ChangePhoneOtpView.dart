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

class ChangePhoneOtpView extends StatefulWidget {
  ChangePhoneOtpView({Key key, this.isHaveArrow, this.phone}) : super(key: key);
  final String isHaveArrow;
  final String phone;

  @override
  _ChangePhoneOtpViewState createState() => _ChangePhoneOtpViewState();
}

class _ChangePhoneOtpViewState extends State<ChangePhoneOtpView> {
  var user = User();
  bool isLogin = false;

  final _otp = TextEditingController();
  bool _validateOTP = false;

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

  //changePhone
  checkOtp() async {
    Map _map = {};
    _map.addAll({
      "otp": _otp.text,
      "telephone": widget.phone,
    });

    print("_map" + _map.toString());
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
      changePhone();
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }

    if (FocusScope.of(context).isFirstFocus) {
      FocusScope.of(context).requestFocus(new FocusNode());
    }
    EasyLoading.dismiss();
  }

  //changePhone
  changePhone() async {
    Map _map = {};
    _map.addAll({
      "phone": widget.phone,
      "uid": user.uid,
      "username": user.username,
      "isPassOtp": "1",
    });

    print("_map" + _map.toString());
    var body = json.encode(_map);
    return postChangePhone(http.Client(), body, _map);
  }

  Future<List<AllList>> postChangePhone(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().changePhone),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    if (status == "success") {
      user.username = widget.phone;
      user.phone = widget.phone;
      //Navigator.pop(context);
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
        title: "เปลี่ยนเบอร์โทรศัพท์",
        isHaveArrow: widget.isHaveArrow,
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
                Container(
                  child: Text(
                    "ระบุรหัส OTP ที่ได้รับจาก SMS",
                    textAlign: TextAlign.center,
                  ),
                ),

                //otop
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
                          MaterialStateProperty.all<Color>(Color(0xFF65A5D8)),
                    ),
                    onPressed: () {
                      setState(() {
                        _otp.text.isEmpty
                            ? _validateOTP = true
                            : _validateOTP = false;
                        if (!_validateOTP) {
                          if (FocusScope.of(context).isFirstFocus) {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          }
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
