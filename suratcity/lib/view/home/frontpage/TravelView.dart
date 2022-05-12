import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cvapp/view/nearview/NearMeView.dart';
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
  var title = "เที่ยว";
  var tid = "1";
  int _currentPage = 0;

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
  Color selectedColor = Color(0xFF8C1F78);
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
      title = "เที่ยว";
    } else if (currentTab == 2) {
      fnName = Info().eatList;
      tid = "3";
      title = "กิน";
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NearMeView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/main/charm_bg.png',
                    ),
                  ),
                ),
                Expanded(
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
                        color: Color(0xFF8C1F78),
                      ),
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
                                        "$tempWeather°",
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
              ],
            ),
            Container(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 500,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage("assets/images/main/travel_bg.png"),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter),
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(9.0),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(top: 0, left: 8, right: 8),
                        child: Center(
                          child: Column(
                            children: [
                              //travelTab
                              Container(
                                margin: EdgeInsets.only(top: 92),
                                padding: EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          getTravel(1);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9.0),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/main/t1.png',
                                                    height: 32,
                                                    color: (currentTab == 1)
                                                        ? selectedColor
                                                        : normalColor,
                                                  ),
                                                  SizedBox(
                                                    height: 4.0,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "เที่ยว",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Kanit',
                                                        color: (currentTab == 1)
                                                            ? selectedColor
                                                            : normalColor,
                                                      ),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          getTravel(2);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9.0),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/main/t2.png',
                                                    height: 32,
                                                    color: (currentTab == 2)
                                                        ? selectedColor
                                                        : normalColor,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "กิน",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Kanit',
                                                        color: (currentTab == 2)
                                                            ? selectedColor
                                                            : normalColor,
                                                      ),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          getTravel(3);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9.0),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/main/t3.png',
                                                    height: 32,
                                                    color: (currentTab == 3)
                                                        ? selectedColor
                                                        : normalColor,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "พัก",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Kanit',
                                                        color: (currentTab == 3)
                                                            ? selectedColor
                                                            : normalColor,
                                                      ),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          getTravel(4);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(9.0),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/main/t4.png',
                                                    height: 32,
                                                    color: (currentTab == 4)
                                                        ? selectedColor
                                                        : normalColor,
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      "ชอป",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontFamily: 'Kanit',
                                                        color: (currentTab == 4)
                                                            ? selectedColor
                                                            : normalColor,
                                                      ),
                                                    ),
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //contentTravel
                              (data != null && data.length != 0)
                                  ? CarouselSlider.builder(
                                      options: CarouselOptions(
                                          height: 269.0,
                                          enlargeCenterPage: true,
                                          autoPlayCurve: Curves.fastOutSlowIn,
                                          autoPlay: false,
                                          aspectRatio: 2.5,
                                          viewportFraction: 0.6,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentPage = index;
                                            });
                                          }),
                                      itemCount: data.length,
                                      itemBuilder: (BuildContext context,
                                          int index, int realIndex) {
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TravelDetailView(
                                                  topicID: data[index]["id"]
                                                      .toString(),
                                                  title: title,
                                                  tid: tid,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.network(
                                                    data[index]
                                                        ["display_image"],
                                                    height: 269.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                8.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                8.0),
                                                      ),
                                                      color: Colors.black
                                                          .withOpacity(0.5),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        data[index]["subject"]
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'Sriracha',
                                                          color: Colors.white,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
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
                                            builder: (context) =>
                                                TravelListView(
                                              isHaveArrow: "1",
                                              title: "เที่ยว",
                                              tid: "1",
                                            ),
                                          ),
                                        );
                                      } else if (currentTab == 2) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TravelListView(
                                              isHaveArrow: "1",
                                              title: "กิน",
                                              tid: "3",
                                            ),
                                          ),
                                        );
                                      } else if (currentTab == 3) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TravelListView(
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
                                            builder: (context) =>
                                                TravelListView(
                                              isHaveArrow: "1",
                                              title: "ชอป",
                                              tid: "4",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Center(
                                      child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Image.asset(
                                          'assets/images/main/more.png',
                                          height: 24,
                                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Container(
//                                   margin: EdgeInsets.only(top: 4),
//                                   child: Column(
//                                     children: [
//                                       //top1
//                                       if (data != null && data.length != 0)
//                                         GestureDetector(
//                                           onTap: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (context) =>
//                                                     TravelDetailView(
//                                                   topicID:
//                                                       data[0]["id"].toString(),
//                                                   title: title,
//                                                   tid: tid,
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                 Radius.circular(9.0),
//                                               ),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: Colors.grey
//                                                       .withOpacity(0.5),
//                                                   spreadRadius: 3,
//                                                   blurRadius: 7,
//                                                   offset: Offset(0,
//                                                       3), // changes position of shadow
//                                                 ),
//                                               ],
//                                               color: Colors.white,
//                                             ),
//                                             width: MediaQuery.of(context)
//                                                 .size
//                                                 .width,
//                                             height: 180,
//                                             child: Column(
//                                               children: [
//                                                 Expanded(
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.only(
//                                                         topRight:
//                                                             Radius.circular(
//                                                                 9.0),
//                                                         topLeft:
//                                                             Radius.circular(
//                                                                 9.0),
//                                                       ),
//                                                       image: DecorationImage(
//                                                         /*image: AssetImage(
//                             "assets/images/main/test.jpg"),*/
//                                                         image: NetworkImage(
//                                                           data[0]
//                                                               ["display_image"],
//                                                         ),
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                   padding: EdgeInsets.all(16),
//                                                   alignment:
//                                                       Alignment.centerLeft,
//                                                   child: Text(
//                                                     data[0]["subject"],
//                                                     //fnName.toString() + widget.tab,
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style:
//                                                         TextStyle(fontSize: 12),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       //top2-3
//                                       Row(
//                                         children: [
//                                           if (data != null && data.length != 0)
//                                             if (data.length >= 2)
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             TravelDetailView(
//                                                           topicID: data[1]["id"]
//                                                               .toString(),
//                                                           title: title,
//                                                           tid: tid,
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     margin:
//                                                         EdgeInsets.symmetric(
//                                                             horizontal: 4,
//                                                             vertical: 8),
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                         Radius.circular(9.0),
//                                                       ),
//                                                       boxShadow: [
//                                                         BoxShadow(
//                                                           color: Colors.grey
//                                                               .withOpacity(0.5),
//                                                           spreadRadius: 3,
//                                                           blurRadius: 7,
//                                                           offset: Offset(0,
//                                                               3), // changes position of shadow
//                                                         ),
//                                                       ],
//                                                       color: Colors.white,
//                                                     ),
//                                                     width:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .width *
//                                                             0.44,
//                                                     height: 150,
//                                                     child: Column(
//                                                       children: [
//                                                         Expanded(
//                                                           child: Container(
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .only(
//                                                                 topRight: Radius
//                                                                     .circular(
//                                                                         9.0),
//                                                                 topLeft: Radius
//                                                                     .circular(
//                                                                         9.0),
//                                                               ),
//                                                               image:
//                                                                   DecorationImage(
//                                                                 image:
//                                                                     NetworkImage(
//                                                                   data[1][
//                                                                       "display_image"],
//                                                                 ),
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Container(
//                                                           padding:
//                                                               EdgeInsets.all(8),
//                                                           alignment: Alignment
//                                                               .centerLeft,
//                                                           child: Text(
//                                                             data[1]["subject"],
//                                                             maxLines: 1,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             style: TextStyle(
//                                                                 fontSize: 12),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                           if (data != null && data.length != 0)
//                                             if (data.length >= 3)
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             TravelDetailView(
//                                                           topicID: data[2]["id"]
//                                                               .toString(),
//                                                           title: title,
//                                                           tid: tid,
//                                                         ),
//                                                       ),
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     margin:
//                                                         EdgeInsets.symmetric(
//                                                             horizontal: 4,
//                                                             vertical: 8),
//                                                     decoration: BoxDecoration(
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                         Radius.circular(9.0),
//                                                       ),
//                                                       boxShadow: [
//                                                         BoxShadow(
//                                                           color: Colors.grey
//                                                               .withOpacity(0.5),
//                                                           spreadRadius: 3,
//                                                           blurRadius: 7,
//                                                           offset: Offset(0,
//                                                               3), // changes position of shadow
//                                                         ),
//                                                       ],
//                                                       color: Colors.white,
//                                                     ),
//                                                     width:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .width *
//                                                             0.44,
//                                                     height: 150,
//                                                     child: Column(
//                                                       children: [
//                                                         Expanded(
//                                                           child: Container(
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .only(
//                                                                 topRight: Radius
//                                                                     .circular(
//                                                                         9.0),
//                                                                 topLeft: Radius
//                                                                     .circular(
//                                                                         9.0),
//                                                               ),
//                                                               image:
//                                                                   DecorationImage(
//                                                                 image:
//                                                                     NetworkImage(
//                                                                   data[2][
//                                                                       "display_image"],
//                                                                 ),
//                                                                 fit: BoxFit
//                                                                     .cover,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Container(
//                                                           padding:
//                                                               EdgeInsets.all(8),
//                                                           alignment: Alignment
//                                                               .centerLeft,
//                                                           child: Text(
//                                                             data[2]["subject"],
//                                                             maxLines: 1,
//                                                             overflow:
//                                                                 TextOverflow
//                                                                     .ellipsis,
//                                                             style: TextStyle(
//                                                                 fontSize: 12),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )