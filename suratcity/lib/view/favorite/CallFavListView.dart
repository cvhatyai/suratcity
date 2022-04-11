import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/phone/PhoneDetailView.dart';
import 'package:cvapp/view/travel/TravelDetailView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CallFavListView extends StatefulWidget {
  @override
  _CallFavListViewState createState() => _CallFavListViewState();
}

class _CallFavListViewState extends State<CallFavListView> {
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
          if (tmpFav2[1] == "callList") {
            getList(tmpFav2[1], tmpFav2[0]);
          }
        }
      } else {
        print("fff");
      }
    }
  }

  getList(fnName, id) async {
    Map _map = {};
    _map.addAll({"allId": id, "rows": "100"});

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postList(http.Client(), body, _map, fnName);
  }

  Future<List<AllList>> postList(
      http.Client client, jsonMap, Map map, fnName) async {
    if (fnName == "callList") {
      tmpFnName = Info().callList;
    }

    final response = await client.post(Uri.parse(tmpFnName),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    parseList(response.body);
  }

  List<AllList> parseList(String responseBody) {
    data.addAll(json.decode(responseBody));
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      color: Color(0xFFFFFFFF),
      padding: EdgeInsets.only(left: 8, right: 8),
      child: (data != null && data.length != 0)
          ? GroupedListView<dynamic, String>(
              elements: data,
              groupBy: (element) => element['session_header'],
              useStickyGroupSeparators: true,
              groupSeparatorBuilder: (String value) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              itemBuilder: (c, element) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhoneDetailView(
                          isHaveArrow: "1",
                          id: element["id"],
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
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                element["display_image"],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      element["subject"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      element["tel"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                      ],
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
    );
  }
}
