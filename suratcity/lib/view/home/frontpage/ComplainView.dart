import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/complain/ComplainCateListView.dart';
import 'package:cvapp/view/complain/ComplainFormView.dart';
import 'package:cvapp/view/complain/FollowComplainListView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:cvapp/view/news/NewsListView.dart';
import 'package:http/http.dart' as http;

var data;

class ComplainView extends StatefulWidget {
  @override
  _ComplainViewState createState() => _ComplainViewState();
}

class _ComplainViewState extends State<ComplainView> {
  var user = User();
  bool isLogin = false;
  List<Color>  boxColors = [
    Color(0xFFCC141A),
    Color(0xFFC440B7),
    Color(0xFFA65CE7),
    Color(0xFF5CC1E7),
    Color(0xFF22925B),
    Color(0xFF6AB92D),
    Color(0xFFD2AB2C),
    Color(0xFFFC5D17),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
    getComplainList();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
    });
  }

  getComplainList() async {
    Map _map = {};
    _map.addAll({
      "rows": "8",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postComplainList(http.Client(), body, _map);
  }

  Future<List<AllList>> postComplainList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateInformList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
    data = [];
    data.addAll(json.decode(responseBody));

    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;

    BoxDecoration boxWhite() {
      return BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
        color: Color(0xFFF5F6FA),
        borderRadius: BorderRadius.all(
          Radius.circular(9.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      );
    }

    return Container(
      color: Color(0xFFf5f6fa),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.all(
          //   Radius.circular(9.0),
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.5),
          //     spreadRadius: 3,
          //     blurRadius: 7,
          //     offset: Offset(0, 3), // changes position of shadow
          //   ),
          // ],
        ),
        margin: EdgeInsets.only(
          top: 8,
          bottom: 14,
          right: 8,
          left: 8,
        ),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/main/hand.png',
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        color: Color(0xFFFFF600),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "แจ้งเรื่อง",
                            style: TextStyle(
                              color: Color(0xFFA335AB),
                              fontSize: 18,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Color(0xFFA335AB),
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "ร้องเรียนร้องทุกข์",
                            style: TextStyle(
                              color: Color(0xFFFFF600),
                              fontSize: 18,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.only(top: 0),
                  child: Center(
                    child: (data != null && data.length != 0)
                        ? GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            childAspectRatio: (itemWidth / itemHeight),
                            crossAxisCount: 4,
                            children: List.generate(data.length, (index) {
                              return GestureDetector(
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
                                        builder: (context) => ComplainFormView(
                                          topicID: data[index]["id"].toString(),
                                          subjectTitle: data[index]["subject"],
                                          displayImage: data[index]
                                              ["display_image"],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    decoration: boxWhite(),
                                    margin: EdgeInsets.all(4),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(10.0),
                                                  topRight:
                                                      Radius.circular(10.0)),
                                              color: boxColors[index],
                                            ),
                                            width: double.infinity,
                                            padding: EdgeInsets.all(6),
                                            child: Image.network(
                                              data[index]["display_image"],
                                              color: Colors.white,
                                              fit: BoxFit.fitHeight,
                                              alignment:
                                                  FractionalOffset.topCenter,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.all(4),
                                            child: Text(
                                              data[index]["subject"],
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          )
                        : Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Center(child: Text("ไม่มีข้อมูล")),
                          ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.only(bottom: 8),
                  alignment: Alignment.centerRight,
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
                    child: Image.asset(
                      'assets/images/main/more.png',
                      height: 24,
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(bottom: 16),
                //   alignment: Alignment.centerLeft,
                //   child: GestureDetector(
                //     onTap: () {
                //       if (!isLogin) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => LoginView(
                //               isHaveArrow: "1",
                //             ),
                //           ),
                //         );
                //       } else {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => FollowComplainListView(
                //               isHaveArrow: "1",
                //             ),
                //           ),
                //         );
                //       }
                //     },
                //     child: Stack(
                //       alignment: AlignmentDirectional.center,
                //       children: [
                //         Container(
                //           alignment: Alignment.centerLeft,
                //           child: Image.asset(
                //             'assets/images/main/more_complain.png',
                //             height: 36,
                //           ),
                //         ),
                //         Container(
                //           padding: EdgeInsets.only(left: 4),
                //           child: Row(
                //             children: [
                //               Text(
                //                 "ติดตามเรื่องร้องเรียน",
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   color: Colors.white,
                //                 ),
                //               ),
                //               Icon(
                //                 Icons.arrow_forward_ios,
                //                 color: Colors.white,
                //                 size: 12,
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
