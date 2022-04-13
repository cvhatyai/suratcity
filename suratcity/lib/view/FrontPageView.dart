import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/FirebaseNotification.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/news/NewsDetailView.dart';

import 'package:cvapp/view/news/NewsListView.dart';
import 'package:cvapp/view/noti/NotiListView.dart';
import 'package:cvapp/view/search/SearchView.dart';
import 'package:cvapp/view/webpageview/WebPageView.dart';

import 'chat/ChatView.dart';
import 'complain/ComplainAdminDetailView.dart';
import 'complain/ComplainDetailView.dart';
import 'gallery/GalleryDetailView.dart';
import 'home/HomeView.dart';
import 'menu/MenuView.dart';

class FrontPageView extends StatefulWidget {
  FrontPageView({
    Key key,
    this.payload = "",
  }) : super(key: key);
  String payload;

  @override
  _FrontPageViewState createState() => _FrontPageViewState();
}

class _FrontPageViewState extends State<FrontPageView> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = [HomeView(), NewsListView(), ChatView(), NotiListView(), MenuView()];

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

    if (isLogin) {
      _widgetOptions = [HomeView(), NewsListView(), ChatView(), NotiListView(), MenuView()];
    } else {
      _widgetOptions = [HomeView(), NewsListView(), ChatView(), LoginView(), MenuView()];
    }

    if (widget.payload != null) {
      if (widget.payload != "null") {
        if (widget.payload != "") {
          checkIsHasFromNotiBanner();
        }
      }
    }
  }

  //กดจาก noti ใหม่
  checkIsHasFromNotiBanner() {
    print("checkIsHasFromNotiBanner");
    print("aa : " + widget.payload.toString());
    final rs = json.decode(widget.payload.toString());
    widget.payload = "";
    print("id : " + rs["id"]);
    print("fn_name : " + rs["fn_name"]);
    print("menu : " + rs["menu"]);

    gotoDetail(rs["fn_name"], rs["id"]);
  }

  gotoDetail(fnName, topicID) {
    print("fnName : " + fnName);
    print("topicID : " + topicID);
    if (fnName == "newsDetail") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailView(topicID: topicID.toString()),
        ),
      );
    } else if (fnName == "galleryDetail") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryDetailView(topicID: topicID.toString()),
        ),
      );
    } else {
      if (isLogin) {
        if (fnName == "informDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComplainDetailView(topicID: topicID.toString()),
            ),
          );
        } else if (fnName == "informAdminDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComplainAdminDetailView(topicID: topicID.toString()),
            ),
          );
        } else if (fnName == "taxAdmin") {
          if (user.userclass != "member") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPageView(
                  isHaveArrow: "1",
                  title: "รายการภาษี",
                  cmd: "tax_admin",
                  edit: topicID,
                ),
              ),
            );
          }
        } else if (fnName == "disabledAdmin") {
          if (user.userclass != "member") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPageView(
                  isHaveArrow: "1",
                  title: "รายการเบี้ยยังชีพผู้พิการ",
                  cmd: "disabled_admin",
                  edit: topicID,
                ),
              ),
            );
          }
        } else if (fnName == "disabledDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageView(
                isHaveArrow: "1",
                title: "รายการเบี้ยยังชีพผู้พิการ",
                cmd: "disabled",
                edit: topicID,
              ),
            ),
          );
        } else if (fnName == "elderAdmin") {
          if (user.userclass != "member") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebPageView(
                  isHaveArrow: "1",
                  title: "รายการเบี้ยยังชีพผู้สูงอายุ",
                  cmd: "elder_admin",
                  edit: topicID,
                ),
              ),
            );
          }
        } else if (fnName == "elderDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageView(
                isHaveArrow: "1",
                title: "รายการเบี้ยยังชีพผู้สูงอายุ",
                cmd: "elder",
                edit: topicID,
              ),
            ),
          );
        } else if (fnName == "garbageDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageView(
                isHaveArrow: "1",
                title: "ชำระค่าขยะ",
                cmd: "garbage",
                edit: topicID,
              ),
            ),
          );
        } else if (fnName == "taxDetail") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageView(
                isHaveArrow: "1",
                title: "ชำระภาษี",
                cmd: "tax",
                edit: topicID,
              ),
            ),
          );
        } else if (fnName == "taxHistory") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebPageView(
                isHaveArrow: "1",
                title: "ชำระภาษี",
                cmd: "taxHistory",
                edit: "",
              ),
            ),
          );
        }
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F2F6),
        body: Container(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/main/menu_bar.png'), fit: BoxFit.fill),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.white,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            onTap: _onItemTapped,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/home.png',
                  color: Colors.white,
                  height: 22,
                ),
                label: 'หน้าแรก',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/newspaper.png',
                  color: Colors.white,
                  height: 22,
                ),
                label: 'ข่าว',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/search_btn.png',
                  color: Colors.white,
                  height: 22,
                ),
                label: 'ค้นหา',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/noti.png',
                  color: Colors.white,
                  height: 22,
                ),
                label: 'แจ้งเตือน',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/list.png',
                  color: Colors.white,
                  height: 22,
                ),
                label: 'เมนูอื่น',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
