import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/complain/ComplainCateListView.dart';
import 'package:cvapp/view/complain/FollowComplainListView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/poll/PollView.dart';
import 'package:cvapp/view/webpageview/WebPageView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

class EserviceView extends StatefulWidget {
  EserviceView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _EserviceViewState createState() => _EserviceViewState();
}

class _EserviceViewState extends State<EserviceView> {
  var user = User();
  bool isLogin = false;

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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: "E-Service",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFFFFFFF),
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  //ชำระบริการ
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ชำระบริการ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(
                          0xFF4283C4,
                        ),
                      ),
                    ),
                  ),
                  //icon
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              } else {
                                if (user.userclass == "member") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebPageView(
                                        isHaveArrow: "1",
                                        title: "ชำระภาษี",
                                        cmd: "tax",
                                      ),
                                    ),
                                  );
                                } else {
                                  Toast.show(
                                      "User ดังกล่าวไม่สามารถใช้งานส่วนนี้ได้ หากต้องใช้งานกรุณาออกจากระบบ Admin ก่อน",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug2.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "ชำระภาษี",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              } else {
                                if (user.userclass == "member") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebPageView(
                                        isHaveArrow: "1",
                                        title: "ชำระค่าขยะ",
                                        cmd: "garbage",
                                      ),
                                    ),
                                  );
                                } else {
                                  Toast.show(
                                      "User ดังกล่าวไม่สามารถใช้งานส่วนนี้ได้ หากต้องใช้งานกรุณาออกจากระบบ Admin ก่อน",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug3.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "ชำระค่าขยะ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  //line
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Divider(),
                  ),
                  //สวัสดิการ
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "สวัสดิการ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(
                          0xFF4283C4,
                        ),
                      ),
                    ),
                  ),
                  //icon
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              } else {
                                if (user.userclass == "member") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebPageView(
                                        isHaveArrow: "1",
                                        title: "เบี้ยยังชีพผู้สูงอายุ",
                                        cmd: "elder",
                                      ),
                                    ),
                                  );
                                } else {
                                  Toast.show(
                                      "User ดังกล่าวไม่สามารถใช้งานส่วนนี้ได้ หากต้องใช้งานกรุณาออกจากระบบ Admin ก่อน",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug7.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "เบี้ยยังชีพ ผู้สูงอายุ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _launchInBrowser(
                                  "http://csgcheck.dcy.go.th/public/eq/popSubsidy.do");
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug8.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "อุดหนุน เด็กแรกเกิด",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              } else {
                                if (user.userclass == "member") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WebPageView(
                                        isHaveArrow: "1",
                                        title: "เบี้ยยังชีพผู้พิการ",
                                        cmd: "disabled",
                                      ),
                                    ),
                                  );
                                } else {
                                  Toast.show(
                                      "User ดังกล่าวไม่สามารถใช้งานส่วนนี้ได้ หากต้องใช้งานกรุณาออกจากระบบ Admin ก่อน",
                                      context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug4.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "เบี้ยยังชีพผู้พิการ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //line
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Divider(),
                  ),
                  //บริการอื่นๆ
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "บริการอื่นๆ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(
                          0xFF4283C4,
                        ),
                      ),
                    ),
                  ),
                  //icon
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComplainCateListView(
                                    isHaveArrow: "1",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug5.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "แจ้งเรื่องร้องเรียน",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!isLogin) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FollowComplainListView(
                                      isHaveArrow: "1",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug6.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "ติดตามเรื่อง\nร้องเรียน/ร้องทุกข์",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PollView(
                                    isHaveArrow: "1",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.28,
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/main/sug1.png',
                                    height: 42,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "ประเมินความ\nพึงพอใจ",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //line
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: Divider(),
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
