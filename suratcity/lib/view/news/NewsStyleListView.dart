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

class NewsStyleListView extends StatefulWidget {
  NewsStyleListView(
      {Key key,
      this.isHaveArrow = "",
      this.cid,
      this.title,
      this.isHasCate = false})
      : super(key: key);
  final String isHaveArrow;
  final String cid;
  final String title;
  final bool isHasCate;

  @override
  _NewsStyleListViewState createState() => _NewsStyleListViewState();
}

class _NewsStyleListViewState extends State<NewsStyleListView> {
  final keyword = TextEditingController();

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
    if (data != null) {
      data.clear();
    }
    super.dispose();
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

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "network_news",
      "parent_id": "3",
    });
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateSubList),
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
            style: TextStyle(color: Color(0xFF7C1B6A)),
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
      "rows": "100",
      "cid": (cateVal != "" && cateVal != "0") ? cateVal : widget.cid,
      "keyword": keyword.text,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: widget.title,
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
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: keyword,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์คำค้นหา เช่น ชื่อโครงการ',
                        hintStyle: TextStyle(
                          fontSize: 12,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            getNewsList();
                          },
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF00B9FF),
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                                  builder: (context) => NewsDetailView(
                                      topicID: data[index]["id"].toString()),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Card(
                                color: Color(0xFFF5F6FA),
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
