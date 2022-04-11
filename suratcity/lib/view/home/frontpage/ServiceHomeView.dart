import 'package:flutter/material.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/view/complain/ComplainCateListView.dart';
import 'package:cvapp/view/complain/FollowComplainListView.dart';
import 'package:cvapp/view/eservice/EserviceView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/poll/PollView.dart';
import 'package:cvapp/view/serviceGuide/ServiceGuideListView.dart';
import 'package:cvapp/view/webpageview/WebPageView.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceHomeView extends StatefulWidget {
  @override
  _ServiceHomeViewState createState() => _ServiceHomeViewState();
}

class _ServiceHomeViewState extends State<ServiceHomeView> {
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
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/main/service_bg.png',
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    "E-Service",
                    style: TextStyle(color: Color(0xFF4283C4), fontSize: 18),
                  ),
                  /*Text(
                    "แนะนำ",
                    style: TextStyle(color: Color(0xFFEFAE13), fontSize: 18),
                  ),*/
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              height: 78,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
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
                  GestureDetector(
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
                  GestureDetector(
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
                  GestureDetector(
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
                  GestureDetector(
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
                  GestureDetector(
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
                  GestureDetector(
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
                            builder: (context) => FollowComplainListView(
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
                  GestureDetector(
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
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 8),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceGuideListView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );*/

                  //เปลี่ยนใหม่
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EserviceView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/main/more.png',
                  height: 24,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
