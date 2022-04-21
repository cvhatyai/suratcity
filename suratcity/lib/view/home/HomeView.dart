import 'package:cvapp/view/FrontPageView.dart';
import 'package:cvapp/view/chat/ChatView.dart';
import 'package:cvapp/view/noti/NotiListView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/home/frontpage/ServiceHomeView.dart';
import 'package:cvapp/view/home/frontpage/MarqueeView.dart';
import 'package:cvapp/view/home/frontpage/BannerView.dart';
import 'package:cvapp/view/home/frontpage/SuggustView.dart';
import 'package:cvapp/view/home/frontpage/NewsView.dart';
import 'package:cvapp/view/home/frontpage/ComplainView.dart';
import 'package:cvapp/view/home/frontpage/ComplainFollowView.dart';
import 'package:cvapp/view/home/frontpage/GalleryView.dart';
import 'package:cvapp/view/home/frontpage/TravelView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/setting/SettingView.dart';

import 'frontpage/Activity.dart';
import 'frontpage/FooterView.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var user = User();
  bool isLogin = false;
  var userAvatar = Info().baseUrl + "images/nopic-personal.png";
  var userNoti = Info().baseUrl + "images/nopic-noti.png";

  void initState() {
    super.initState();
    getUsers();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
      if (isLogin) {
        userAvatar = user.avatar;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFFF),
          child: Column(
            children: [
              //top marquee banner
              Stack(
                children: [
                  Image.asset(
                    'assets/images/main/top_bg.png',
                    fit: BoxFit.cover,
                    alignment: FractionalOffset.topCenter,
                  ),
                  Column(
                    children: [
                      //top
                      Container(
                        height: 55,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(),
                            ),
                            // Expanded(
                            //   flex: 3,
                            //   child: Image.asset(
                            //     'assets/images/main/logo_top.png',
                            //   ),
                            // ),
                            Expanded(
                              flex: 3,
                              child: Container(),
                            ),
                            Expanded(
                              flex: 1,
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
                                        builder: (context) => SettingView(
                                          isHaveArrow: "1",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundImage:
                                              NetworkImage(userAvatar),
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 8),
                                        child: Image.asset(
                                          'assets/images/main/noti_top.png',
                                          width: 36,
                                          height: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
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
                                        builder: (context) => NotiListView(
                                          isHaveArrow: "1",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(userNoti),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FrontPageView(
                                tab: "2",
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/main/search.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      //marquee
                      MarqueeView(),
                      //banner
                      // BannerView(),
                    ],
                  ),
                ],
              ),
              //บริการแนะนำ
              //ServiceHomeView(),
              //แนะนำสำหรับคุณ
              SuggustView(),
              //แจ้งเรื่องร้องเรียน/ร้องทุกข์
              //ComplainView(),
              //บรรเทาความเดือดร้อนล่าสุด
              ComplainFollowView(),
              //ทน.สุราษฎร์ธานีอัพเดท
              NewsView(),
              //กิจกรรมห้ามพลาด
              GalleryView(),
              //กิจกรรมห้ามพลาด
              Activity(),
              // //เสน่ห์เมืองนนท์
              // TravelView(),
              // //footer
              // FooterView(),
            ],
          ),
        ),
      ),
    );
  }
}
