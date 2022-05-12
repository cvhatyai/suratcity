import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/travel/TravelDetailView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TravelFavListView extends StatefulWidget {
  @override
  _TravelFavListViewState createState() => _TravelFavListViewState();
}

class _TravelFavListViewState extends State<TravelFavListView> {
  var data = [];
  List<String> arrFav = [];
  var tmpFnName = Info().travelList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getList();
    initFav();
  }

  @override
  void dispose() {
    data.clear();
    super.dispose();
  }

  initFav() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    arrFav = prefs.getStringList("favList");
    print("initFav");
    print(arrFav);

    if (arrFav != null) {
      if (arrFav.isNotEmpty) {
        print("ttt");
        for (var i = 0; i < arrFav.length; i++) {
          var tmpFav = arrFav[i];
          var tmpFav2 = tmpFav.split("_");
          if (tmpFav2[1] != "callList") {
            getList(tmpFav2[1], tmpFav2[0]);
          }
        }
      } else {
        print("fff");
      }
    }
  }

  getList(fnName, id) async {
    print("fnName : " + fnName);
    print("id : " + id);
    Map _map = {};
    _map.addAll({"allId": id, "rows": "100"});

    EasyLoading.show(status: 'loading...');
    var body = json.encode(_map);
    return postList(http.Client(), body, _map, fnName);
  }

  Future<List<AllList>> postList(
      http.Client client, jsonMap, Map map, fnName) async {
    if (fnName == "travelList") {
      tmpFnName = Info().travelList;
    } else if (fnName == "eatList") {
      tmpFnName = Info().eatList;
    } else if (fnName == "restList") {
      tmpFnName = Info().restList;
    } else if (fnName == "shopList") {
      tmpFnName = Info().shopList;
    }

    final response = await client.post(Uri.parse(tmpFnName),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    parseList(response.body);
  }

  List<AllList> parseList(String responseBody) {
    data.addAll(json.decode(responseBody));
    print("data" + data.toString());
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  getTitle(fn_name) {
    var title = "เที่ยว";
    if (fn_name == "travelDetail") {
      title = "เที่ยว";
    } else if (fn_name == "restDetail") {
      title = "พัก";
    } else if (fn_name == "eatDetail") {
      title = "กิน";
    } else if (fn_name == "shopDetail") {
      title = "ชอป";
    }
    return title;
  }

  getTid(fn_name) {
    var title = "1";
    if (fn_name == "travelDetail") {
      title = "1";
    } else if (fn_name == "restDetail") {
      title = "2";
    } else if (fn_name == "eatDetail") {
      title = "3";
    } else if (fn_name == "shopDetail") {
      title = "4";
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 3.2;
    final double itemWidth = size.width / 2;

    return Container(
      color: Color(0xFFFFFFFF),
      padding: EdgeInsets.only(left: 8, right: 8),
      child: (data != null && data.length != 0)
          ? GridView.count(
              childAspectRatio: (itemWidth / itemHeight),
              crossAxisCount: 2,
              children: List.generate(data.length, (index) {
                return GestureDetector(
                  onTap: () {
                    print("getTitle : " +
                        getTitle(data[index]["fn_name"].toString()));
                    print("getTid : " +
                        getTid(data[index]["fn_name"].toString()));

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelDetailView(
                          topicID: data[index]["id"].toString(),
                          title: getTitle(data[index]["fn_name"].toString()),
                          tid: getTid(data[index]["fn_name"].toString()),
                        ),
                      ),
                    ).then((value) {
                      setState(() {
                        data.clear();
                      });
                      initFav();
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Card(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
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
                              flex: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    data[index]["subject"],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
