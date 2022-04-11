import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/complain/FinishedComplainListView.dart';

import 'package:http/http.dart' as http;

import 'package:cvapp/view/complain/ComplainDetailView.dart';

var data;

class ComplainFollowView extends StatefulWidget {
  @override
  _ComplainFollowViewState createState() => _ComplainFollowViewState();
}

class _ComplainFollowViewState extends State<ComplainFollowView> {
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
    final response = await client.post(Uri.parse(Info().informFinishList),
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
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "บรรเทาความเดือดร้อนล่าสุด",
                style: TextStyle(color: Color(0xFF4283C4), fontSize: 18),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              height: 180,
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
                                  builder: (context) => ComplainDetailView(
                                      topicID: data[i]["id"].toString(),
                                      title: "บรรเทาความเดือดร้อนล่าสุด",
                                      isShow: "1"),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Colors.black,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                child: Image.network(
                                                  data[i]["img_before"],
                                                  fit: BoxFit.cover,
                                                ),
                                                height: 90,
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Image.asset(
                                                  'assets/images/main/before.png',
                                                  height: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Colors.black,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                child: Image.network(
                                                  data[i]["img_after"],
                                                  fit: BoxFit.cover,
                                                ),
                                                height: 90,
                                              ),
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Image.asset(
                                                  'assets/images/main/after.png',
                                                  height: 40,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data[i]["subject"],
                                          style: TextStyle(fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_pin,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            Expanded(
                                              child: Text(
                                                data[i]["near_location"],
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.event_available_rounded,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            Text(
                                              data[i]["finish_date"],
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                        builder: (context) => FinishedComplainListView(
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
          ],
        ),
      ),
    );
  }
}
