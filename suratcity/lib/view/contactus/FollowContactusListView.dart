import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'ContactusDetailView.dart';

var data;

class FollowContactusListView extends StatefulWidget {
  FollowContactusListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _FollowContactusListViewState createState() =>
      _FollowContactusListViewState();
}

class _FollowContactusListViewState extends State<FollowContactusListView> {
  var user = User();
  bool isLogin = false;
  var uid = "";

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
    });
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "uid": uid,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().contactusList),
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
          title: "ติดตามเรื่องที่ติดต่อ",
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactusDetailView(
                              topicID: data[index]["id"].toString(),
                              reply: data[index]["reply"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(9.0),
                          ),
                          border: Border.all(
                            color: Color(0xFF8C1F78),
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
                                      color: Color(0xFF8C1F78),
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
                                          "3 พ.ค. 64",
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
