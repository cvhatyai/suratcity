import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/complain/ComplainAdminDetailView.dart';
import 'package:cvapp/view/complain/ComplainDetailView.dart';
import 'package:cvapp/view/news/NewsDetailView.dart';
import 'package:cvapp/view/webpageview/WebPageView.dart';

import '../AppBarView.dart';

var data;

class NotiListView extends StatefulWidget {
  NotiListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _NotiListViewState createState() => _NotiListViewState();
}

class _NotiListViewState extends State<NotiListView> {
  var user = User();
  bool isLogin = false;

  var userClass = "";
  var uid = "";

  void initState() {
    super.initState();
    getUsers();
    getNewsList();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
    });
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "userclass": user.userclass,
      "uid": user.uid,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().notiList),
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
    } else if (fnName == "informDetail") {
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
          builder: (context) =>
              ComplainAdminDetailView(topicID: topicID.toString()),
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
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsDetailView(topicID: topicID.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "การแจ้งเตือน",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: (data != null && data.length != 0)
            ? ListView(
                children: [
                  for (var i = 0; i < data.length; i++)
                    GestureDetector(
                      onTap: () {
                        gotoDetail(data[i]["fn_name"], data[i]["topic_id"]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(9.0),
                          ),
                          color: Color(0xFFF5F6FA),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        height: 85,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data[i]["subject"],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        Container(
                                            child: Text(
                                          data[i]["create_date"],
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF2DA3FF),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Text("ไม่มีข้อมูล")),
              ),
      ),
    ));
  }
}
