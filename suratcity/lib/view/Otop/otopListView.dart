import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../AppBarView.dart';
import 'otopDetailView.dart';

var data;

//dropdown
var arrMapPerson;
String cateValPerson = "";
Map<int, String> dataCateMapPerson = {0: "-- เลือกกอง --"};
//dropdown

class otopListView extends StatefulWidget {
  otopListView({Key key, this.isHaveArrow = "", this.cateDefault = ""})
      : super(key: key);
  final String isHaveArrow;
  String cateDefault;
  @override
  _otopListViewState createState() => _otopListViewState();
}

class _otopListViewState extends State<otopListView> {
  var userFullname;
  var uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCatePersonList();
    getUserDetail();
  }

  getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userFullname = prefs.getString('userFullname').toString();
      uid = prefs.getString('uid').toString();
    });
    getNewsList();
  }

  getCatePersonList() {
    Map _map = {};
    _map.addAll({
      "cmd": "service_guide",
      "parent_id": "1",
    });
    var body = json.encode(_map);
    return postCatePersonData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCatePersonData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateAllList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    return parseCatePersonData(response.body);
  }

  List<AllList> parseCatePersonData(String responseBody) {
    //print("responseBody" + responseBody.toString());
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    arrMapPerson =
        parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    print("arrMap" + arrMapPerson.toString());

    Map<int, String> tmpDataCateMapPerson;
    tmpDataCateMapPerson = Map.fromIterable(arrMapPerson,
        key: (e) => e.id, value: (e) => e.cate_name);
    dataCateMapPerson.addAll(tmpDataCateMapPerson);

    print("dataCateMap" + dataCateMapPerson.toString());

    setState(() {});

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  String dropdownValue3 = (cateValPerson != "") ? cateValPerson : "0";

  Widget dropDownCatePerson() {
    return (arrMapPerson != null && arrMapPerson.length != 0)
        ? DropdownButton<String>(
            value: widget.cateDefault == "no" ? "0" : dropdownValue3,
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
                dropdownValue3 = newValue;
                cateValPerson = dropdownValue3;
                widget.cateDefault = cateValPerson;
                getNewsList();
                // getCateSubList();
                print("cateValPerson" + cateValPerson);
              });
            },
            items: dataCateMapPerson.entries
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

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
      "pid": cateValPerson,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().otopList),
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
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 3.2;
    final double itemWidth = size.width / 2;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "OTOP",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Column(
        children: [
          Visibility(
            visible: false,
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: dropDownCatePerson(),
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.only(left: 8, right: 8, top: 8),
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
                                builder: (context) => otopDetailView(
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
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0)),
                                  child: Image.network(
                                    data[index]["display_image"],
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 80,
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
                                                    color: Color(0xFF7C1B6A),
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
