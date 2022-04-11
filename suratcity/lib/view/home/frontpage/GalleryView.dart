import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/calendar/CalendarDetailView.dart';
import 'package:cvapp/view/calendar/CalendarListView.dart';
import 'package:cvapp/view/gallery/GalleryDetailView.dart';
import 'package:cvapp/view/gallery/GalleryListView.dart';
import 'package:http/http.dart' as http;

var data;
var data2;

class GalleryView extends StatefulWidget {
  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsList();
    getActivtyList();
  }

  //activity
  getActivtyList() async {
    Map _map = {};
    _map.addAll({
      "rows": "2",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postActivityList(http.Client(), body, _map);
  }

  Future<List<AllList>> postActivityList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().eventsList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseActivityList(response.body);
  }

  List<AllList> parseActivityList(String responseBody) {
    data2 = [];
    data2.addAll(json.decode(responseBody));

    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  //gallery
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
    final response = await client.post(Uri.parse(Info().galleryList),
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

  //tab
  Color tabTextColorNormal = Color(0xFF707070);
  Color tabTextColorActive = Color(0xFF4283C4);
  Color indicatorTabColorNormal = Color(0xFFFFFFFF);
  Color indicatorTabColorActive = Color(0xFFFCC402);
  bool isFirstTabActivated = true;

  changeTab() {
    setState(() {
      if (isFirstTabActivated) {
        isFirstTabActivated = false;
      } else {
        isFirstTabActivated = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFf5f6fa),
      child: Container(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 8, top: 28),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isFirstTabActivated) {
                          changeTab();
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              "ภาพกิจกรรม",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (isFirstTabActivated)
                                    ? tabTextColorActive
                                    : tabTextColorNormal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Divider(
                            color: (isFirstTabActivated)
                                ? indicatorTabColorActive
                                : indicatorTabColorNormal,
                            thickness: 3,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isFirstTabActivated) {
                          changeTab();
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              "กิจกรรมห้ามพลาด",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: (!isFirstTabActivated)
                                    ? tabTextColorActive
                                    : tabTextColorNormal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Divider(
                            color: (!isFirstTabActivated)
                                ? indicatorTabColorActive
                                : indicatorTabColorNormal,
                            thickness: 3,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (isFirstTabActivated)
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        height: 240,
                        margin: EdgeInsets.only(top: 8),
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
                                            builder: (context) =>
                                                GalleryDetailView(
                                                    topicID: data[i]["id"]
                                                        .toString()),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 4),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 7,
                                                    offset: Offset(
                                                      0,
                                                      1,
                                                    ), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              height: 135,
                                              child: Image.network(
                                                data[i]["display_image"],
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 1,
                                                    blurRadius: 7,
                                                    offset: Offset(
                                                      0,
                                                      1,
                                                    ), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              height: 80,
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        data[i]["subject"],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      data[i]["create_date"],
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Color(0xFF6399C4),
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
                              )
                            : Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: Center(child: Text("ไม่มีข้อมูล")),
                              ),
                      ),
                      if (data != null && data.length != 0)
                        Container(
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GalleryListView(
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
                        )
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        height: 240,
                        margin: EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text("วันที่"),
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: 1,
                                        height: 30,
                                        color: Colors.black12,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: EdgeInsets.only(left: 16),
                                    child: Text("กิจกรรม"),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Container(
                                color: Color(0xFFFFFFFF),
                                child: (data2 != null && data2.length != 0)
                                    ? ListView.builder(
                                        itemCount: data2.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            data2[index]
                                                                ["sdate"],
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .deepOrange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text("-" +
                                                              data2[index]
                                                                  ["edate"]),
                                                        ],
                                                      ),
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          data2[index]
                                                              ["smonth"],
                                                          style: TextStyle(
                                                              fontSize: 9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 20,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 1,
                                                      height: 80,
                                                      color: Colors.black12,
                                                    ),
                                                    Positioned(
                                                      top: 30,
                                                      child: Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .blueAccent,
                                                              width: 4),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            CalendarDetailView(
                                                                topicID: data2[
                                                                            index]
                                                                        ["id"]
                                                                    .toString()),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 70,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(9.0),
                                                      ),
                                                      border: Border.all(
                                                          color:
                                                              Colors.black12),
                                                      color: Colors.white,
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8),
                                                    padding: EdgeInsets.all(6),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                data2[index]
                                                                    ["subject"],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style:
                                                                    TextStyle(
                                                                        height:
                                                                            1),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 4),
                                                                child: Text(
                                                                  data2[index][
                                                                      "location"],
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        })
                                    : Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child:
                                            Center(child: Text("ไม่มีข้อมูล")),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data2 != null && data2.length != 0)
                        Container(
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarListView(
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
                        )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
