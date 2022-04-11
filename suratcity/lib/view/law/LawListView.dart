import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'LawDetailView.dart';

var data;

//dropdown
var arrMap;
String cateVal = "";
Map<int, String> dataCateMap = {0: "-- เลือกหมวด --"};
//dropdown

class LawListView extends StatefulWidget {
  LawListView(
      {Key key, this.isHaveArrow = "", this.title = "", this.keyword = ""})
      : super(key: key);
  final String isHaveArrow;
  final String title;
  final String keyword;

  @override
  _LawListViewState createState() => _LawListViewState();
}

class _LawListViewState extends State<LawListView> {
  var userFullname;
  var uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetail();
  }

  @override
  void dispose() {
    data.clear();
    dataCateMap = {0: "-- เลือกหมวด --"};
    if (arrMap != null) {
      arrMap.clear();
    }
    cateVal = "";
    super.dispose();
  }

  getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userFullname = prefs.getString('userFullname').toString();
      uid = prefs.getString('uid').toString();
    });
    getCateList();
    getNewsList();
  }

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "news_rule",
    });
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateList),
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

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "uid": uid,
      "cmd": "news_rule",
      "row": "200",
      "cid": cateVal,
      "keyword": widget.keyword,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().newsDocumentList),
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: "ระเบียบข้อกฏหมาย/ข้อบัญญัติ",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: dropDownCate(),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 8),
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
                                  builder: (context) => LawDetailView(
                                    topicID: data[index]["id"],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Card(
                                color: Color(0xFFF1F9FF),
                                child: ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height *
                                            0.08,
                                  ),
                                  child: Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Icon(
                                            Icons.circle,
                                            color: Color(0xFF707070),
                                            size: 12,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            child: Text(
                                              data[index]["subject"],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}
