import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'TravelDetailView.dart';
import 'TravelCommentAddView.dart';

var data;

class TravelCommentListView extends StatefulWidget {
  TravelCommentListView({Key key, this.topicID}) : super(key: key);
  final String topicID;

  @override
  _TravelCommentListViewState createState() => _TravelCommentListViewState();
}

class _TravelCommentListViewState extends State<TravelCommentListView> {
  var userAvatar = Info().baseUrl + "images/nopic-personal.jpg";

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
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ความคิดเห็น",
        isHaveArrow: "1",
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xFFFFFFFF),
            padding: EdgeInsets.only(left: 8, right: 8),
            child: (data != null && data.length != 0)
                ? ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      if (data[index]["avatar"] != "") {
                        userAvatar = data[index]["avatar"];
                      } else {
                        userAvatar =
                            Info().baseUrl + "images/nopic-personal.jpg";
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
                                    backgroundImage: NetworkImage(userAvatar),
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
                                          color: Color(0xFFAAAAAA),
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
                    builder: (context) => TravelCommentAddView(
                      topicID: widget.topicID,
                    ),
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue,
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
    ));
  }
}
