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

import 'frontpage/FooterView.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var user = User();
  bool isLogin = false;
  var userAvatar = Info().baseUrl + "images/nopic-personal.png";

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
          color: Color(0xFFF1F2F6),
          child: Column(
            children: [
              //top marquee banner
              Stack(
                children: [
                  Image.asset(
                    'assets/images/main/top_bg.png',
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
                            Image.asset(
                              'assets/images/main/menu_top_left.png',
                              width: 27,
                              height: 20,
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
                                        backgroundImage: NetworkImage(userAvatar),
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
                          ],
                        ),
                      ),

                      Stack(
                        children: [
                          Column(
                            children: [
                              //logo
                              Stack(
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/main/bg_head.png',
                                    ),
                                  ),

                                  Container(
                                    margin: EdgeInsets.only(top: 6),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/main/logo_top.png',
                                      width: 160,
                                      height: 85.68,
                                    ),
                                  ),

                                ],
                              ),

                              //search
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 42),
                                color: Color(0xFFF1F2F6),
                                height: 60,
                                child:  Image.asset(
                                  'assets/images/main/search_bg.png',
                                ),
                              ),
                            ],
                          ),

                          Container(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              'assets/images/main/search_right.png',
                              width: 73.5,
                              height: 154.32,
                            ),
                          ),

                        ],
                      ),

                      //marquee
                      MarqueeView(),
                    ],
                  ),
                ],
              ),
              //บริการแนะนำ
              //ServiceHomeView(),
              //แนะนำสำหรับคุณ
              //SuggustView(),
              //ทม.กระบี่อัพเดท
              //NewsView(),
              //แจ้งเรื่องร้องเรียน/ร้องทุกข์
              //ComplainView(),
              //บรรเทาความเดือดร้อนล่าสุด
              //ComplainFollowView(),
              //กิจกรรมห้ามพลาด
              //GalleryView(),
              //เสน่ห์เมืองนนท์
              //TravelView(),
              //footer
              //FooterView(),
            ],
          ),
        ),
      ),
    );
  }
}
