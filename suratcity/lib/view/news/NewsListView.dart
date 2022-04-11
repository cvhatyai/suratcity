import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'NewsDetailView.dart';

var data;

//dropdown
var arrMap;
String cateVal = "";
Map<int, String> dataCateMap = {0: "-- เลือกหมวด --"};
//dropdown

//dropdownsub
var arrMapSub;
String cateValSub = "";
Map<int, String> dataCateMapSub = {0: "-- เลือกหมวด --"};
//dropdownsub

class NewsListView extends StatefulWidget {
  NewsListView({Key key, this.isHaveArrow = "", this.isHasCate = true})
      : super(key: key);
  final String isHaveArrow;
  final bool isHasCate;

  @override
  _NewsListViewState createState() => _NewsListViewState();
}

class _NewsListViewState extends State<NewsListView> {
  var userFullname;
  var uid;
  bool isHasSubCate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetail();
  }

  getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userFullname = prefs.getString('userFullname').toString();
      uid = prefs.getString('uid').toString();
    });
    if (widget.isHasCate) {
      getCateList();
    }
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
      "cid": cateVal,
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
    //print("responseBodyList1" + responseBody);
    data = [];
    data.addAll(json.decode(responseBody));
    //print("responseBodyList2" + data.toString());

    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  BoxDecoration boxWhite() {
    return BoxDecoration(
      /*borderRadius: BorderRadius.all(
        Radius.circular(9.0),
      ),*/
      border: Border.all(
        color: Colors.white,
        width: 1.0,
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

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "network_news",
      "parent_id": "1",
    });
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateAllList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCateData(response.body);
  }

  List<AllList> parseCateData(String responseBody) {
    //print("responseBody" + responseBody.toString());
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMap = parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    print("arrMap" + arrMap.toString());

    Map<int, String> tmpDataCateMap;
    tmpDataCateMap =
        Map.fromIterable(arrMap, key: (e) => e.id, value: (e) => e.cate_name);
    dataCateMap.addAll(tmpDataCateMap);

    print("dataCateMap" + dataCateMap.toString());

    setState(() {});

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  String dropdownValue2 = (cateVal != "") ? cateVal : "0";

  Widget dropDownCate() {
    return (arrMap != null && arrMap.length != 0)
        ? DropdownButton<String>(
            value: dropdownValue2,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_outlined),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.blue),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue2 = newValue;
                cateVal = dropdownValue2;
                getNewsList();
                getCateSubList();
                print("cateVal" + cateVal);
              });
            },
            items: dataCateMap.entries
                .map<DropdownMenuItem<String>>(
                    (MapEntry<int, String> e) => DropdownMenuItem<String>(
                          value: e.key.toString(),
                          child: Text(
                            e.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                .toList(),
          )
        : Container();
  }

  //dropdown

  //dropdownsub
  getCateSubList() {
    Map _map = {};
    _map.addAll({
      "cmd": "network_news",
      "parent_id": cateVal,
    });
    var body = json.encode(_map);
    return postCateSubData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateSubData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateAllList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCateSubData(response.body);
  }

  List<AllList> parseCateSubData(String responseBody) {
    //print("responseBody" + responseBody.toString());
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMapSub = parsed.map<AllList>((json) => AllList.fromJson(json)).toList();

    Map<int, String> tmpDataCateMap;
    tmpDataCateMap = Map.fromIterable(arrMapSub,
        key: (e) => e.id, value: (e) => e.cate_name);
    dataCateMapSub.addAll(tmpDataCateMap);

    if (arrMapSub != null && arrMapSub.length != 0) {
      setState(() {
        isHasSubCate = true;
      });
    }

    print("dataCateMap" + dataCateMapSub.toString());

    setState(() {});

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  String dropdownValue2Sub = (cateValSub != "") ? cateValSub : "0";

  Widget dropDownCateSub() {
    return (arrMapSub != null && arrMapSub.length != 0)
        ? DropdownButton<String>(
            value: dropdownValue2Sub,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_outlined),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.blue),
            underline: Container(
              height: 1,
              color: Colors.grey,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue2Sub = newValue;
                cateValSub = dropdownValue2Sub;
                cateVal = cateValSub;
                getNewsList();
                print("cateVal" + cateVal);
              });
            },
            items: dataCateMapSub.entries
                .map<DropdownMenuItem<String>>(
                    (MapEntry<int, String> e) => DropdownMenuItem<String>(
                          value: e.key.toString(),
                          child: Text(
                            e.value,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ))
                .toList(),
          )
        : Container();
  }

  //dropdownsub

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 3.2;
    final double itemWidth = size.width / 2;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ทม.กระบี่อัพเดท",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Column(
        children: [
          Visibility(
            visible: widget.isHasCate ? true : false,
            child: Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: dropDownCate(),
            ),
          ),
          Visibility(
            visible: isHasSubCate ? true : false,
            child: Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: dropDownCateSub(),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.only(left: 8, right: 8),
              child: (data != null && data.length != 0)
                  ? GridView.count(
                      childAspectRatio: (itemWidth / itemHeight),
                      crossAxisCount: 2,
                      children: List.generate(data.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailView(
                                    topicID: data[index]["id"].toString()),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Image.network(
                                  data[index]["display_image"],
                                  fit: BoxFit.fill,
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
                                        0.42,
                                    height: 85,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              data[index]["subject"],
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data[index]["create_date"],
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF6399C4),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/view.png',
                                                    height: 12,
                                                  ),
                                                  if (data[index]["hits2"] !=
                                                      "")
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: 4),
                                                      child: Text(
                                                        data[index]["hits2"],
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                ],
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
                          ),
                        );
                      }),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text("ไม่มีข้อมูล")),
                    ),
            ),
          ),
        ],
      ),
    ));
  }
}
