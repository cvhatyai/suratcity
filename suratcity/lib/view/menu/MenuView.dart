import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/calendar/CalendarListView.dart';
import 'package:cvapp/view/chat/ChatView.dart';
import 'package:cvapp/view/complain/ComplainCateListView.dart';
import 'package:cvapp/view/complain/FollowComplainListView.dart';
import 'package:cvapp/view/contactdev/ContactDevView.dart';
import 'package:cvapp/view/contactus/ContactusView.dart';
import 'package:cvapp/view/contactus/FollowContactusListView.dart';
import 'package:cvapp/view/download/DownloadListView.dart';
import 'package:cvapp/view/law/LawListView.dart';
import 'package:cvapp/view/ebook/EbookListView.dart';
import 'package:cvapp/view/gallery/GalleryListView.dart';
import 'package:cvapp/view/general/GeneralView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/news/NewsListView.dart';
import 'package:cvapp/view/news/NewsStyleListView.dart';
import 'package:cvapp/view/faq/FaqWebView.dart';
import 'package:cvapp/view/phone/PhoneCateListView.dart';
import 'package:cvapp/view/phone/PhoneListView.dart';
import 'package:cvapp/view/poll/PollView.dart';
import 'package:cvapp/view/serviceGuide/ServiceGuideListView.dart';
import 'package:cvapp/view/travel/TravelListView.dart';
import 'package:cvapp/view/video/VideoListView.dart';
import 'package:cvapp/view/setting/SettingView.dart';
import 'package:cvapp/view/favorite/FavoriteView.dart';
import 'package:cvapp/view/webpageview/WebPageView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../FrontPageView.dart';

class MenuView extends StatefulWidget {
  @override
  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  var userFullname = "เข้าสู่ระบบ";
  var userClass = "เข้าสู่ระบบ";
  var uid = "";
  var userAvatar = Info().baseUrl + "images/nopic-personal.jpg";

  var guideLink = "";
  var favCount = 0;
  List<String> arrFav = [];

  /*PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );*/

  var user = User();
  bool isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EasyLoading.show(status: 'loading...');
    getSiteDetail();
    getUsers();
    initFav();
    Timer(Duration(seconds: 1), () => EasyLoading.dismiss());
    //_initPackageInfo();
  }

  initFav() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    arrFav = prefs.getStringList("favList");
    setState(() {
      if (arrFav != null) {
        favCount = arrFav.length;
      }
    });
  }

  /*Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }*/

  //siteGuide
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
      guideLink = rs["guide_link"].toString();
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

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
      if (isLogin) {
        userFullname = user.fullname;
        userAvatar = user.avatar;
        print("userAvataruserAvatar" + userAvatar);
      }
    });
  }

  Future<void> logout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ยืนยันการออกจากระบบ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ยืนยัน'),
              onPressed: () {
                user.logout();
                //clearPref();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FrontPageView()),
                  ModalRoute.withName("/"),
                );
                Toast.show("ออกจากระบบแล้ว", context,
                    duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                //Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  clearPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  clearPoll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("isVoted");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      //สีเดียว
      color: Colors.white,
      //ไล่สี
      /*decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            Color(0xFF65DF92),
            Color(0xFF10B3A8),
            Color(0xFF11B4A8),
          ],
        ),
      ),*/
      child: ListView(
        children: [
          //topmenu
          Container(
            child: Stack(
              children: [
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/menu_bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.only(right: 16),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (guideLink != "") {
                                      _launchInBrowser(guideLink);
                                    } else {
                                      Toast.show("ไม่มีข้อมูล", context,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(18),
                                        topRight: Radius.circular(18),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "คู่มือสำหรับผู้ใช้งาน",
                                          style: TextStyle(
                                            color: Color(0xFF5B5B5F),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.blueAccent,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    FrontPageView()),
                                            ModalRoute.withName("/"),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: 4, left: 4),
                                          child: Icon(
                                            Icons.home,
                                            color: Colors.white,
                                            size: 30,
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
                                                builder: (context) =>
                                                    SettingView(
                                                  isHaveArrow: "1",
                                                ),
                                              ),
                                            ).then((value) {
                                              getUsers();
                                            });
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: 4, left: 4),
                                          child: Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FavoriteView(
                                                isHaveArrow: "1",
                                              ),
                                            ),
                                          ).then((value) {
                                            setState(() {
                                              initFav();
                                            });
                                          });
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  right: 4, left: 4),
                                              child: Icon(
                                                Icons.bookmark_sharp,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                            if (favCount != 0)
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Text(
                                                    favCount.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            margin: EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                Container(
                                  child: CircleAvatar(
                                    radius: 24.0,
                                    backgroundImage: NetworkImage(userAvatar),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Text(
                                            userFullname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22),
                                          ),
                                        ),
                                      ),
                                      if (isLogin)
                                        Container(
                                          padding: EdgeInsets.only(left: 8),
                                          child: GestureDetector(
                                            onTap: () {
                                              logout();
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "ออกจากระบบ",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(top: 2),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //top menu2
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 32),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              "ติดต่อ/แจ้งเรื่องร้องเรียน",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF4B4B4B),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(bottom: 16),
                          ),
                          Row(
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ComplainCateListView(
                                            isHaveArrow: "1",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/menu/top1.png',
                                        height: 32,
                                      ),
                                      Text(
                                        "แจ้งเรื่อง\nร้องเรียน",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                color: Color(0xFFE3E3E3),
                                height: 40,
                                width: 1,
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
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/menu/top2.png',
                                        height: 32,
                                      ),
                                      Text(
                                        "ติดตามเรื่อง\nร้องเรียน",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                color: Color(0xFFE3E3E3),
                                height: 40,
                                width: 1,
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
                                          builder: (context) => ContactusView(
                                            isHaveArrow: "1",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/menu/top3.png',
                                        height: 32,
                                      ),
                                      Text(
                                        "ติดต่อ\nเจ้าหน้าที่",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                color: Color(0xFFE3E3E3),
                                height: 40,
                                width: 1,
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
                                              FollowContactusListView(
                                            isHaveArrow: "1",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/menu/top4.png',
                                        height: 32,
                                      ),
                                      Text(
                                        "ติดตามเรื่อง\nที่ติดต่อ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //top menu
              ],
            ),
          ),

          //title menu 1
          if (user.userclass != "superadmin" && user.userclass != "admin")
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              alignment: Alignment.centerLeft,
              color: Color(0xFFE2F2FF),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ชำระภาษี/ค่าบริการ",
                    style: TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          //sub menu 1
          if (user.userclass != "superadmin" && user.userclass != "admin")
            GestureDetector(
              onTap: () {
                if (isLogin) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m1.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "ชำระภาษี",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass != "superadmin" && user.userclass != "admin")
            GestureDetector(
              onTap: () {
                if (isLogin) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m2.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "ชำระค่าขยะ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),

          //title menu 2
          if (user.userclass != "superadmin" && user.userclass != "admin")
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              alignment: Alignment.centerLeft,
              color: Color(0xFFE2F2FF),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "สวัสดิการ/เบี้ยยังชีพ",
                    style: TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          //sub menu 2
          if (user.userclass != "superadmin" && user.userclass != "admin")
            GestureDetector(
              onTap: () {
                if (isLogin) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m3.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "เบี้ยยังชีพผู้สูงอายุ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass != "superadmin" && user.userclass != "admin")
            GestureDetector(
              onTap: () {
                if (isLogin) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m4.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "เบี้ยยังชีพผู้พิการ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),

          //title menu 3
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            color: Color(0xFFE2F2FF),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ข้อมูลเกี่ยวกับเทศบาล",
                  style: TextStyle(fontSize: 15),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          //sub menu 3
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m5.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ข้อมูลทั่วไปของเทศบาล",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m6.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ทม.กระบี่อัพเดท",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),

          //new
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsStyleListView(
                    isHaveArrow: "1",
                    cid: "3",
                    title: "ประกาศจัดซื้อจัดจ้าง",
                    isHasCate: true,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m25.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ประกาศจัดซื้อจัดจ้าง",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LawListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m26.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ระเบียบข้อกฏหมาย/ข้อบัญญัติ",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsStyleListView(
                    isHaveArrow: "1",
                    cid: "4",
                    title: "ข่าวสมัครงาน",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m27.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ข่าวสมัครงาน",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m7.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ภาพกิจกรรม",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m8.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "กิจกรรมห้ามพลาด",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m9.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "วิดีโอกิจกรรม",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceGuideListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m10.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "บริการของเทศบาล",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DownloadListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m11.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "เอกสาร/แบบฟอร์ม",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EbookListView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m12.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "วารสาร",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhoneCateListView(
                    isHaveArrow: "1",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m13.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "เบอร์โทรสำคัญ",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PollView(
                    isHaveArrow: "1",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m28.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ประเมินความพึงพอใจ",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),

          //title menu 4
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            color: Color(0xFFE2F2FF),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ข้อมูลท่องเที่ยว",
                  style: TextStyle(fontSize: 15),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          //sub menu 4
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelListView(
                    isHaveArrow: "1",
                    title: "ที่เที่ยว",
                    tid: "1",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m14.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ที่เที่ยว",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelListView(
                    isHaveArrow: "1",
                    title: "ที่กิน",
                    tid: "3",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m15.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ที่กิน",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelListView(
                    isHaveArrow: "1",
                    title: "ชอป",
                    tid: "4",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m16.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ชอป",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TravelListView(
                    isHaveArrow: "1",
                    title: "พัก",
                    tid: "2",
                  ),
                ),
              ).then((value) {
                setState(() {
                  initFav();
                });
              });
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m17.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "พัก",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),

          //title menu 5
          Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            alignment: Alignment.centerLeft,
            color: Color(0xFFE2F2FF),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ติดต่อ",
                  style: TextStyle(fontSize: 15),
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
          //sub menu 5
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaqWebView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m18.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "FAQ ถาม-ตอบ",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
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
                    builder: (context) => ContactusView(
                      isHaveArrow: "1",
                    ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m19.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "ติดต่อเทศบาล",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDevView(
                    isHaveArrow: "1",
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  alignment: Alignment.centerLeft,
                  color: Colors.transparent,
                  height: 40,
                  child: Row(
                    children: [
                      /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                      Image.asset(
                        'assets/images/menu/m20.png',
                        height: 18,
                        width: 18,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Text(
                          "แจ้งปัญหา/ติดต่อผู้พัฒนา",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, indent: 8, endIndent: 8),
              ],
            ),
          ),

          //title menu 6
          if (user.userclass == "superadmin" || user.userclass == "admin")
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              alignment: Alignment.centerLeft,
              color: Color(0xFFE2F2FF),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "สำหรับเจ้าหน้าที่",
                    style: TextStyle(fontSize: 15),
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          //sub menu 6
          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowComplainListView(
                      isHaveArrow: "1",
                      title: "ตรวจสอบเรื่องร้องเรียน",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m21.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "ตรวจสอบเรื่องร้องเรียน",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "แผนที่แสดงจุดเรื่องร้องเรียน",
                      cmd: "map_complain",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m22.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "แผนที่แสดงจุดเรื่องร้องเรียน",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "กราฟสรุปผลเรื่องร้องเรียน",
                      cmd: "graph_complain",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m23.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "กราฟสรุปผลเรื่องร้องเรียน",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "รายการภาษี",
                      cmd: "tax_admin",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m24.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "รายการภาษี",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),
          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "รายการค่าขยะ",
                      cmd: "garbage_admin",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m2.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "รายการค่าขยะ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),

          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "รายการเบี้ยยังชีพผู้พิการ",
                      cmd: "disabled_admin",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m11.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "รายการเบี้ยยังชีพผู้พิการ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),

          if (user.userclass == "superadmin" || user.userclass == "admin")
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebPageView(
                      isHaveArrow: "1",
                      title: "รายการเบี้ยยังชีพผู้สูงอายุ",
                      cmd: "elder_admin",
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 32),
                    alignment: Alignment.centerLeft,
                    color: Colors.transparent,
                    height: 40,
                    child: Row(
                      children: [
                        /*Image.asset(
                        'assets/images/menu1.png',
                        height: 22,
                        width: 22,
                      ),*/
                        Image.asset(
                          'assets/images/menu/m11.png',
                          height: 18,
                          width: 18,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16),
                          child: Text(
                            "รายการเบี้ยยังชีพผู้สูงอายุ",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, indent: 8, endIndent: 8),
                ],
              ),
            ),

          //version
          /*Stack(
            children: [
              Image.asset(
                'assets/images/btm_version.png',
                width: double.infinity,
              ),
              Container(
                margin: EdgeInsets.only(top: 85),
                padding: EdgeInsets.only(left: 32),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Version " + _packageInfo.version,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Powered by ",
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          "CityVariety Co.,Ltd,",
                          style:
                          TextStyle(color: Colors.blueAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
