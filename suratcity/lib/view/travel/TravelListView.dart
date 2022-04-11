import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/system/InitLove.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'TravelDetailView.dart';
import 'TravelCommentListView.dart';

var data;

class TravelListView extends StatefulWidget {
  TravelListView(
      {Key key, this.isHaveArrow = "", this.title = "", this.tid = ""})
      : super(key: key);
  final String isHaveArrow;
  final String title;
  final String tid;

  @override
  _TravelListViewState createState() => _TravelListViewState();
}

class _TravelListViewState extends State<TravelListView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getList();
  }

  @override
  void dispose() {
    super.dispose();
    data.clear();
  }

  getList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postList(http.Client(), body, _map);
  }

  Future<List<AllList>> postList(http.Client client, jsonMap, Map map) async {
    var fnName = Info().travelList;
    if (widget.tid == "1") {
      fnName = Info().travelList;
    } else if (widget.tid == "2") {
      fnName = Info().restList;
    } else if (widget.tid == "3") {
      fnName = Info().eatList;
    } else if (widget.tid == "4") {
      fnName = Info().shopList;
    }

    final response = await client.post(Uri.parse(fnName),
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
      color: Colors.white,
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
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.6;
    final double itemWidth = size.width / 2;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: widget.title,
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
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
                          builder: (context) => TravelDetailView(
                            topicID: data[index]["id"].toString(),
                            title: widget.title,
                            tid: widget.tid,
                          ),
                        ),
                      ).then((value) {
                        setState(() {
                          data.clear();
                        });
                        getList();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Card(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.33,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(9.0),
                                      topRight: Radius.circular(9.0),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        data[index]["display_image"],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //subject
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            data[index]["subject"],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      //activity
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            children: [
                                              //love
                                              InitLove(
                                                  id: data[index]["id"]
                                                      .toString(),
                                                  cmd: "travel",
                                                  loveCount: data[index]
                                                      ["love"]),
                                              //comment
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TravelCommentListView(
                                                        topicID: data[index]
                                                                ["id"]
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/travel/chat.png',
                                                        height: 16,
                                                      ),
                                                      if (data[index]
                                                              ["comment"] !=
                                                          "")
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 4),
                                                          child: Text(
                                                              data[index]
                                                                  ["comment"]),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //view

                                              if (data[index]["hits"] != "")
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/travel/view.png',
                                                        height: 16,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 4),
                                                        child: Text(data[index]
                                                            ["hits"]),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              //share
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    /*_launchInBrowser(
                                                        data[index]["link"]);*/
                                                    Share.share(
                                                        data[index]["link"],
                                                        subject: data[index]
                                                            ["subject"]);
                                                  },
                                                  child: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Image.asset(
                                                      'assets/images/travel/share.png',
                                                      height: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
    ));
  }
}
