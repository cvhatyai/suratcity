import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/view/news/NewsDetailView.dart';
import 'package:cvapp/view/news/NewsListView.dart';

var data;

class NewsView extends StatefulWidget {
  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "6",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().newsList),
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
    return Container(
      color: Color(0xFFf5f6fa),
      child: Container(
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.all(
        //     Radius.circular(9.0),
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.5),
        //       spreadRadius: 3,
        //       blurRadius: 7,
        //       offset: Offset(0, 3), // changes position of shadow
        //     ),
        //   ],
        // ),
        margin: EdgeInsets.only(
          top: 8,
          bottom: 14,
          right: 8,
          left: 8,
        ),
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
                color: Color(0xFF7C1B6A),
              ),
              padding: EdgeInsets.symmetric(horizontal: 60),
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    color: Colors.white,
                  ),
                  child: Image.asset(
                    'assets/images/main/more_complain.png',
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              height: 200,
              child: (data != null && data.length != 0)
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var i = 0; i < data.length; i++)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsDetailView(
                                      topicID: data[i]["id"].toString()),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(9.0),
                                    ),
                                    child: Image.network(
                                      data[i]["display_image"],
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: Offset(
                                              0,
                                              1,
                                            ), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      height: 80,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                data[i]["subject"],
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 11),
                                              ),
                                            ),
                                            Text(
                                              data[i]["create_date"],
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF7C1B6A),
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
                          ),
                      ],
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("ไม่มีข้อมูล")),
                    ),
            ),
            if (data != null && data.length != 0)
              Container(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsListView(
                          isHaveArrow: "1",
                          cateDefault: "no",
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
          ],
        ),
      ),
    );
  }
}
