import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/travel/TravelDetailView.dart';
import 'package:cvapp/view/travel/TravelListView.dart';
import 'package:cvapp/view/weather/WeatherListView.dart';

class TravelView extends StatefulWidget {
  @override
  _TravelViewState createState() => _TravelViewState();
}

class _TravelViewState extends State<TravelView> {
  int currentTab = 1;
  var title = "ที่เที่ยว";
  var tid = "1";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setWeather();
    getList();
  }

  //weather
  var iconWeather = "";
  var tempWeather = "";
  var textWeather = "";

  setWeather() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postSiteDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postSiteDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().weatherApi),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      iconWeather = rs["icon"].toString();
      tempWeather = rs["temp"].toString();
      textWeather = rs["description"].toString();
    });
  }

  //tab
  Color selectedColor = Color(0xFF1084F8);
  Color selectedTabColor = Color(0xFFFF8000);
  Color normalColor = Color(0xFF979797);

  getTravel(tab) {
    if (tab != currentTab) {
      setState(() {
        currentTab = tab;
        data.clear();
        getList();
      });
    }
  }

  var data = [];
  var fnName = Info().travelList;

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
    if (currentTab == 1) {
      fnName = Info().travelList;
      tid = "1";
      title = "ที่เที่ยว";
    } else if (currentTab == 2) {
      fnName = Info().eatList;
      tid = "3";
      title = "ที่กิน";
    } else if (currentTab == 3) {
      fnName = Info().restList;
      tid = "2";
      title = "พัก";
    } else if (currentTab == 4) {
      fnName = Info().shopList;
      tid = "4";
      title = "ชอป";
    }

    final response = await client.post(Uri.parse(fnName),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
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
        child: Stack(
          children: [
            Image.asset(
              'assets/images/main/charm_bg.png',
            ),
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherListView(
                        isHaveArrow: "1",
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  height: 70,
                  margin: EdgeInsets.only(right: 8),
                  width: MediaQuery.of(context).size.width * 0.48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(9.0),
                      ),
                      color: Colors.black.withOpacity(0.5)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "อากาศทน.สุราษฎร์ธานีวันนี้",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                if (iconWeather != "")
                                  Expanded(
                                    child: Image.network(
                                      iconWeather,
                                      height: 36,
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    "$tempWeather ํ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              textWeather,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 24, top: 8),
                  child: Text(
                    "เสน่ห์เมืองนนท์",
                    style: TextStyle(color: Color(0xFF4283C4), fontSize: 18),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4),
                  margin: EdgeInsets.only(top: 42, left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(9.0),
                    ),
                  ),
                  child: Container(
                    child: Center(
                      child: Column(
                        children: [
                          //travelTab
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      getTravel(1);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/main/travel1.png',
                                              height: 22,
                                              color: (currentTab == 1)
                                                  ? selectedColor
                                                  : normalColor,
                                            ),
                                            Container(
                                              child: Text(
                                                "เที่ยว",
                                                style: TextStyle(
                                                  color: (currentTab == 1)
                                                      ? selectedColor
                                                      : normalColor,
                                                ),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: (currentTab == 1)
                                              ? selectedTabColor
                                              : normalColor,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      getTravel(2);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/main/travel2.png',
                                              height: 22,
                                              color: (currentTab == 2)
                                                  ? selectedColor
                                                  : normalColor,
                                            ),
                                            Container(
                                              child: Text(
                                                "กิน",
                                                style: TextStyle(
                                                  color: (currentTab == 2)
                                                      ? selectedColor
                                                      : normalColor,
                                                ),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: (currentTab == 2)
                                              ? selectedTabColor
                                              : normalColor,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      getTravel(3);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/main/travel3.png',
                                              height: 22,
                                              color: (currentTab == 3)
                                                  ? selectedColor
                                                  : normalColor,
                                            ),
                                            Container(
                                              child: Text(
                                                "พัก",
                                                style: TextStyle(
                                                  color: (currentTab == 3)
                                                      ? selectedColor
                                                      : normalColor,
                                                ),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: (currentTab == 3)
                                              ? selectedTabColor
                                              : normalColor,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      getTravel(4);
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/main/travel4.png',
                                              height: 22,
                                              color: (currentTab == 4)
                                                  ? selectedColor
                                                  : normalColor,
                                            ),
                                            Container(
                                              child: Text(
                                                "ชอป",
                                                style: TextStyle(
                                                  color: (currentTab == 4)
                                                      ? selectedColor
                                                      : normalColor,
                                                ),
                                              ),
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: (currentTab == 4)
                                              ? selectedTabColor
                                              : normalColor,
                                          thickness: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //contentTravel
                          (data != null && data.length != 0)
                              ? Container(
                                  margin: EdgeInsets.only(top: 4),
                                  child: Column(
                                    children: [
                                      //top1
                                      if (data != null && data.length != 0)
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TravelDetailView(
                                                  topicID:
                                                      data[0]["id"].toString(),
                                                  title: title,
                                                  tid: tid,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9.0),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 3,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                              color: Colors.white,
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 180,
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(
                                                                9.0),
                                                        topLeft:
                                                            Radius.circular(
                                                                9.0),
                                                      ),
                                                      image: DecorationImage(
                                                        /*image: AssetImage(
                            "assets/images/main/test.jpg"),*/
                                                        image: NetworkImage(
                                                          data[0]
                                                              ["display_image"],
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(16),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    data[0]["subject"],
                                                    //fnName.toString() + widget.tab,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      //top2-3
                                      Row(
                                        children: [
                                          if (data != null && data.length != 0)
                                            if (data.length >= 2)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TravelDetailView(
                                                          topicID: data[1]["id"]
                                                              .toString(),
                                                          title: title,
                                                          tid: tid,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(9.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 3,
                                                          blurRadius: 7,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                      color: Colors.white,
                                                    ),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.44,
                                                    height: 150,
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        9.0),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        9.0),
                                                              ),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    NetworkImage(
                                                                  data[1][
                                                                      "display_image"],
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            data[1]["subject"],
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          if (data != null && data.length != 0)
                                            if (data.length >= 3)
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TravelDetailView(
                                                          topicID: data[2]["id"]
                                                              .toString(),
                                                          title: title,
                                                          tid: tid,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 8),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(9.0),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 3,
                                                          blurRadius: 7,
                                                          offset: Offset(0,
                                                              3), // changes position of shadow
                                                        ),
                                                      ],
                                                      color: Colors.white,
                                                    ),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.44,
                                                    height: 150,
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        9.0),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        9.0),
                                                              ),
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    NetworkImage(
                                                                  data[2][
                                                                      "display_image"],
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            data[2]["subject"],
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 350,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(child: Text("ไม่มีข้อมูล")),
                                ),
                          //more
                          if (data != null && data.length != 0)
                            Container(
                              padding: EdgeInsets.all(4),
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  if (currentTab == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TravelListView(
                                          isHaveArrow: "1",
                                          title: "ที่เที่ยว",
                                          tid: "1",
                                        ),
                                      ),
                                    );
                                  } else if (currentTab == 2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TravelListView(
                                          isHaveArrow: "1",
                                          title: "ที่กิน",
                                          tid: "3",
                                        ),
                                      ),
                                    );
                                  } else if (currentTab == 3) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TravelListView(
                                          isHaveArrow: "1",
                                          title: "พัก",
                                          tid: "2",
                                        ),
                                      ),
                                    );
                                  } else if (currentTab == 4) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TravelListView(
                                          isHaveArrow: "1",
                                          title: "ชอป",
                                          tid: "4",
                                        ),
                                      ),
                                    );
                                  }
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
