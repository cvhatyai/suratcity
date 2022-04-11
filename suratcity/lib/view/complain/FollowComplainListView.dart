import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'ComplainDetailView.dart';
import 'ComplainAdminDetailView.dart';

var data;

class FollowComplainListView extends StatefulWidget {
  FollowComplainListView(
      {Key key, this.isHaveArrow = "", this.title = "ติดตามเรื่องร้องเรียน"})
      : super(key: key);
  final String isHaveArrow;
  final String title;

  @override
  _FollowComplainListViewState createState() => _FollowComplainListViewState();
}

class _FollowComplainListViewState extends State<FollowComplainListView> {
  var user = User();
  bool isLogin = false;
  var uid = "";
  var userClass = "";

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
      uid = user.uid;
      userClass = user.userclass;
    });
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};

    if (userClass != "admin" && userClass != "superadmin") {
      _map.addAll({
        "uid": uid,
        "rows": "100",
      });
    } else {
      _map.addAll({
        "userclass": userClass,
        "rows": "100",
      });
    }

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().informList),
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: widget.title,
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.only(left: 8, right: 8),
          child: (data != null && data.length != 0)
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (userClass != "admin" && userClass != "superadmin") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplainDetailView(
                                topicID: data[index]["id"].toString(),
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComplainAdminDetailView(
                                topicID: data[index]["id"].toString(),
                                title: widget.title,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(9.0),
                          ),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(top: 4),
                        child: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 0.08,
                          ),
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 12),
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          "เรื่อง " + data[index]["subject"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          data[index]["create_date"],
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            child: Text(
                                              "สถานะ",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          if (data[index]["status"] ==
                                              "รอตรวจสอบ")
                                            Container(
                                              margin: EdgeInsets.only(left: 16),
                                              child: Text(
                                                data[index]["status"],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          if (data[index]["status"] ==
                                              "กำลังดำเนินการ")
                                            Container(
                                              margin: EdgeInsets.only(left: 16),
                                              child: Text(
                                                data[index]["status"],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          if (data[index]["status"] ==
                                              "สิ้นสุด")
                                            Container(
                                              margin: EdgeInsets.only(left: 16),
                                              child: Text(
                                                data[index]["status"],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                          if (data[index]["status"] ==
                                              "ไม่สามารถดำเนินการได้")
                                            Container(
                                              margin: EdgeInsets.only(left: 16),
                                              child: Text(
                                                data[index]["status"],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
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
                          ),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text("ไม่มีข้อมูล")),
                ),
        ),
      ),
    );
  }
}
