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
import 'RePasswordView.dart';

class ForgetPasswordOtpView extends StatefulWidget {
  ForgetPasswordOtpView({Key key, this.isHaveArrow, this.telephone})
      : super(key: key);
  final String isHaveArrow;
  final String telephone;

  @override
  _ForgetPasswordOtpViewState createState() => _ForgetPasswordOtpViewState();
}

class _ForgetPasswordOtpViewState extends State<ForgetPasswordOtpView> {
  final _otp = TextEditingController();
  bool _validateOTP = false;

  //checkHavePhone
  checkOtp() async {
    Map _map = {};
    _map.addAll({
      "telephone": widget.telephone,
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RePasswordView(
            isHaveArrow: "1",
            telephone: widget.telephone,
          ),
        ),
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
                          MaterialStateProperty.all<Color>(Color(0xFF65A5D8)),
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
