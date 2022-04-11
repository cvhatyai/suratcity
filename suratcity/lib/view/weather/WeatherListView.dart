import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';

var data;

class WeatherListView extends StatefulWidget {
  WeatherListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _WeatherListViewState createState() => _WeatherListViewState();
}

class _WeatherListViewState extends State<WeatherListView> {
  var defaultIcon = "https://api.cityvariety.com/weather/icon/rain-day.png";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().weatherListApi),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
    //print("responseBodyList1" + responseBody);
    data = [];
    data.addAll(json.decode(responseBody));
    //print("responseBodyList2" + data.toString());

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
          title: "พยากรณ์อากาศ",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.only(left: 8, right: 8),
          child: (data != null && data.length != 0)
              ? ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    child: Text(
                                      data[index]["date"],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Image.network(
                                    data[index]["icon"],
                                    height: 48,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      data[index]["title"],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
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
      ),
    );
  }
}
