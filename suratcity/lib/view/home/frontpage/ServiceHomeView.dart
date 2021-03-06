import 'package:cvapp/view/contactus/ContactusView.dart';
import 'package:cvapp/view/download/DownloadListView.dart';
import 'package:cvapp/view/nearview/NearMeView.dart';
import 'package:cvapp/view/phone/PhoneCateListView.dart';
import 'package:cvapp/view/travel/TravelListView.dart';
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
    return Container(
      margin: EdgeInsets.only(top: 12),
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/main/service_bg.png"),
          fit: BoxFit.fill,
          alignment: FractionalOffset.topCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 28),
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneCateListView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug1.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????\n?????????????????????????????????...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                          builder: (context) => ComplainCateListView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug2.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????????????????????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug3.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????????????????\n?????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                          builder: (context) => DownloadListView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug4.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????? \n/ ????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "???????????????????????????????????????????????????????????????",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug12.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????????????????\n??????????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "?????????????????????????????????????????????????????????",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug13.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????????????????\n????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Expanded(
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => TravelListView(
                //             isHaveArrow: "1",
                //             title: "??????????????????",
                //             tid: "1",
                //           ),
                //         ),
                //       ).then((value) {
                //         setState(() {
                //           // initFav();
                //         });
                //       });
                //     },
                //     child: Container(
                //       child: Column(
                //         children: [
                //           Image.asset(
                //             'assets/images/main/sug5.png',
                //             height: 69,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(top: 4),
                //             child: Text(
                //               "??????????????????",
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   fontSize: 12, color: Color(0xFFFFF600)),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Expanded(
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => TravelListView(
                //             isHaveArrow: "1",
                //             title: "?????????",
                //             tid: "3",
                //           ),
                //         ),
                //       ).then((value) {
                //         setState(() {
                //           // initFav();
                //         });
                //       });
                //     },
                //     child: Container(
                //       child: Column(
                //         children: [
                //           Image.asset(
                //             'assets/images/main/sug6.png',
                //             height: 69,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(top: 4),
                //             child: Text(
                //               "?????????",
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   fontSize: 12, color: Color(0xFFFFF600)),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Expanded(
                //   child: GestureDetector(
                //     onTap: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => TravelListView(
                //             isHaveArrow: "1",
                //             title: "??????????????????",
                //             tid: "2",
                //           ),
                //         ),
                //       ).then((value) {
                //         // setState(() {
                //         //   initFav();
                //         // });
                //       });
                //     },
                //     child: Container(
                //       child: Column(
                //         children: [
                //           Image.asset(
                //             'assets/images/main/sug7.png',
                //             height: 69,
                //           ),
                //           Container(
                //             margin: EdgeInsets.only(top: 4),
                //             child: Text(
                //               "??????????????????",
                //               textAlign: TextAlign.center,
                //               style: TextStyle(
                //                   fontSize: 12, color: Color(0xFFFFF600)),
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NearMeView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug8.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????? \n ???????????????????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                            builder: (context) => ContactusView(
                              isHaveArrow: "1",
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug9.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "??????????????????\n??????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "????????????????????????",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug10.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "???????????????????????? \n ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "??????????????????????????????",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug11.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "?????????????????????????????? \n ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "??????????????????????????? ?????????????????????????????????????????????????????????????????????",
                              cmd: "complain_medical",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug14.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "????????????????????????????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
                      if (isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebPageView(
                              isHaveArrow: "1",
                              title: "????????????????????????????????????????????????????????????",
                              cmd: "pet",
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
                    child: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/main/sug15.png',
                            height: 69,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "????????????????????????????????????????????????????????????",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFFFFF600)),
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
        ],
      ),
    );
  }
}


// GestureDetector(
//                     onTap: () {
//                       if (!isLogin) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (user.userclass == "member") {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WebPageView(
//                                 isHaveArrow: "1",
//                                 title: "????????????????????????",
//                                 cmd: "tax",
//                               ),
//                             ),
//                           );
//                         } else {
//                           Toast.show(
//                               "User ??????????????????????????????????????????????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????????????????????????????????? Admin ????????????",
//                               context,
//                               duration: Toast.LENGTH_LONG,
//                               gravity: Toast.BOTTOM);
//                         }
//                       }
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug2.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       if (!isLogin) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (user.userclass == "member") {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WebPageView(
//                                 isHaveArrow: "1",
//                                 title: "??????????????????????????????",
//                                 cmd: "garbage",
//                               ),
//                             ),
//                           );
//                         } else {
//                           Toast.show(
//                               "User ??????????????????????????????????????????????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????????????????????????????????? Admin ????????????",
//                               context,
//                               duration: Toast.LENGTH_LONG,
//                               gravity: Toast.BOTTOM);
//                         }
//                       }
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug3.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "??????????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       if (!isLogin) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (user.userclass == "member") {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WebPageView(
//                                 isHaveArrow: "1",
//                                 title: "?????????????????????????????????????????????????????????",
//                                 cmd: "disabled",
//                               ),
//                             ),
//                           );
//                         } else {
//                           Toast.show(
//                               "User ??????????????????????????????????????????????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????????????????????????????????? Admin ????????????",
//                               context,
//                               duration: Toast.LENGTH_LONG,
//                               gravity: Toast.BOTTOM);
//                         }
//                       }
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug4.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "?????????????????????????????????????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       if (!isLogin) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       } else {
//                         if (user.userclass == "member") {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WebPageView(
//                                 isHaveArrow: "1",
//                                 title: "???????????????????????????????????????????????????????????????",
//                                 cmd: "elder",
//                               ),
//                             ),
//                           );
//                         } else {
//                           Toast.show(
//                               "User ??????????????????????????????????????????????????????????????????????????????????????????????????? ???????????????????????????????????????????????????????????????????????????????????? Admin ????????????",
//                               context,
//                               duration: Toast.LENGTH_LONG,
//                               gravity: Toast.BOTTOM);
//                         }
//                       }
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug7.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "????????????????????????????????? ??????????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       if (!isLogin) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       } else {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FollowComplainListView(
//                               isHaveArrow: "1",
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug6.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "????????????????????????????????????\n???????????????????????????/???????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       _launchInBrowser(
//                           "http://csgcheck.dcy.go.th/public/eq/popSubsidy.do");
//                     },
//                     child: Container(
//                       width: MediaQuery.of(context).size.width * 0.28,
//                       child: Column(
//                         children: [
//                           Image.asset(
//                             'assets/images/main/sug8.png',
//                             height: 69,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 4),
//                             child: Text(
//                               "????????????????????? ?????????????????????????????????",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 10,color: Color(0xFFFFF600)),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
                