import 'dart:convert';

import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'MarketCommentAddView.dart';

var data;

class MarketCommentListView extends StatefulWidget {
  MarketCommentListView({Key key, this.topicID}) : super(key: key);
  final String topicID;

  @override
  _MarketCommentListViewState createState() => _MarketCommentListViewState();
}

class _MarketCommentListViewState extends State<MarketCommentListView> {
  var userAvatar = Info().baseUrl + "images/nopic-personal-app.png";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getList();
  }

  @override
  void dispose() {
    setState(() {
      data.clear();
    });
    super.dispose();
  }

  getList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
      "tid": widget.topicID,
      "cmd": "market",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postList(http.Client(), body, _map);
  }

  Future<List<AllList>> postList(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().commentList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseList(response.body);
  }

  List<AllList> parseList(String responseBody) {
    data = [];
    data.addAll(json.decode(responseBody));

    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBarView(
        title: "ความคิดเห็น",
        isHaveArrow: "1",
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/sub.png'),
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: (data != null && data.length != 0)
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          if (data[index]["avatar"] != "") {
                            userAvatar = data[index]["avatar"];
                          } else {
                            userAvatar = Info().baseUrl +
                                "images/nopic-personal-app.png";
                          }
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 8),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundImage:
                                            NetworkImage(userAvatar),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data[index]["name"],
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            data[index]["description"],
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            "โพสต์เมื่อ: " +
                                                data[index]["create_date"],
                                            style: TextStyle(
                                              //color: Color(0xFFAAAAAA),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        },
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: Text("ไม่มีข้อมูล")),
                      ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketCommentAddView(
                          topicID: widget.topicID,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF841B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
