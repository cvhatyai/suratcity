import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/gallery/GalleryDetailView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'ComplainFormView.dart';

var data;

class ComplainCateListView extends StatefulWidget {
  ComplainCateListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _ComplainCateListViewState createState() => _ComplainCateListViewState();
}

class _ComplainCateListViewState extends State<ComplainCateListView> {
  var user = User();
  bool isLogin = false;

  @override
  void initState() {
    // TODO: implement initState
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
    _map.addAll({});

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
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

  BoxDecoration boxWhite() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(9.0),
      ),
      border: Border.all(
        color: Colors.white,
        width: 1.0,
      ),
      color: Color(0xFFF5F6FA),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 4.4;
    final double itemWidth = size.width / 3;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "แจ้งเรื่องร้องเรียน",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFFFFFFFF),
          child: Column(
            children: [
              Container(
                color: Color(0xFFFFFFFF),
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Text("เลือกหมวดหมู่เพื่อแจ้งเรื่อง"),
                alignment: Alignment.centerLeft,
              ),
              Container(
                color: Color(0xFFFFFFFF),
                padding: EdgeInsets.only(left: 16, right: 16),
                child: (data != null && data.length != 0)
                    ? GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: (itemWidth / itemHeight),
                        crossAxisCount: 3,
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
                                margin: EdgeInsets.only(
                                  left: 4,
                                  right: 4,
                                  top: 8,
                                ),
                                //decoration: boxWhite(),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      child: Image.network(
                                        data[index]["display_image"],
                                        height: 24,
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(6),
                                      child: Text(
                                        data[index]["subject"],
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
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
            ],
          ),
        ),
      ),
    ));
  }
}
