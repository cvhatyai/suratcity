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
import 'ChangePhoneOtpView.dart';

class ChangePhoneView extends StatefulWidget {
  ChangePhoneView({Key key, this.isHaveArrow}) : super(key: key);
  final String isHaveArrow;

  @override
  _ChangePhoneViewState createState() => _ChangePhoneViewState();
}

class _ChangePhoneViewState extends State<ChangePhoneView> {
  var user = User();
  bool isLogin = false;

  final _phone = TextEditingController();
  bool _validatePhone = false;

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
  changePhone() async {
    Map _map = {};
    _map.addAll({
      "phone": _phone.text,
      "uid": user.uid,
      "username": user.username,
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
      //user.username = usernameRs;
      //Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePhoneOtpView(
            isHaveArrow: "1",
            phone: _phone.text,
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
        title: "เปลี่ยนเบอร์โทรศัพท์",
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
                    controller: _phone,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'เบอร์โทรศัพท์',
                      errorText:
                          _validatePhone ? 'กรุณากรอกเบอร์โทรศัพท์' : null,
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
                        _phone.text.isEmpty
                            ? _validatePhone = true
                            : _validatePhone = false;
                        if (!_validatePhone) {
                          if (FocusScope.of(context).isFirstFocus) {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          }
                          EasyLoading.show(status: 'loading...');
                          changePhone();
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
