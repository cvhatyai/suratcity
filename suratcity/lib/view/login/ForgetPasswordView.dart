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
import 'ForgetPasswordOtpView.dart';

class ForgetPasswordView extends StatefulWidget {
  ForgetPasswordView({Key key, this.isHaveArrow}) : super(key: key);
  final String isHaveArrow;

  @override
  _ForgetPasswordViewState createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _username = TextEditingController();
  bool _validateUsername = false;

  var appName = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSiteDetail();
  }

  getSiteDetail() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postSiteDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postSiteDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().siteDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      appName = rs["name"].toString();
    });
  }

  //checkHavePhone
  checkHavePhone() async {
    Map _map = {};
    _map.addAll({
      "telephone": _username.text,
    });
    var body = json.encode(_map);
    return postCheckHavePhone(http.Client(), body, _map);
  }

  Future<List<AllList>> postCheckHavePhone(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().checkHavePhone),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();

    if (status == "success") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ForgetPasswordOtpView(
            isHaveArrow: "1",
            telephone: _username.text,
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
                    "กรุณากรอกเบอร์โทรศัพท์\nที่สมัครสมาชิกกับ$appName",
                    textAlign: TextAlign.center,
                  ),
                ),
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
                        _username.text.isEmpty
                            ? _validateUsername = true
                            : _validateUsername = false;
                        if (!_validateUsername) {
                          EasyLoading.show(status: 'loading...');
                          checkHavePhone();
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
