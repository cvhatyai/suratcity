import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'citizenGuideDetailView.dart';

var data;

class citizenGuideCateView extends StatefulWidget {
  citizenGuideCateView(
      {Key key,
      this.isHaveArrow = "",
      this.title = "",
      this.cid = "",
      this.keyword = ""})
      : super(key: key);
  final String isHaveArrow;
  final String title;
  final String cid;
  final String keyword;

  @override
  _citizenGuideCateViewState createState() =>
      _citizenGuideCateViewState();
}

class _citizenGuideCateViewState extends State<citizenGuideCateView> {
  var userFullname;
  var uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetail();
  }

  @override
  void dispose() {
    setState(() {
      data.clear();
    });
    super.dispose();
  }

  getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userFullname = prefs.getString('userFullname').toString();
      uid = prefs.getString('uid').toString();
    });
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "uid": uid,
      "cid": widget.cid,
      "keyword": widget.keyword,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().citizenGuideList),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => citizenGuideDetailView(
                              topicID: data[index]["id"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Card(
                          color: Color(0xFFF1F9FF),
                          child: ConstrainedBox(
                            constraints: new BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.08,
                            ),
                            child: Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.circle,
                                      color: Color(0xFF707070),
                                      size: 12,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      child: Text(
                                        data[index]["subject"],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
