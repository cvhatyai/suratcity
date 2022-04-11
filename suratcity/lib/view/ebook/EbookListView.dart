import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

var data;

//dropdown
var arrMap;
String cateVal = "";
Map<int, String> dataCateMap = {0: "-- เลือกหมวด --"};
//dropdown

class EbookListView extends StatefulWidget {
  EbookListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _EbookListViewState createState() => _EbookListViewState();
}

class _EbookListViewState extends State<EbookListView> {
  var userFullname;
  var uid;

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
    getCateList();
    getNewsList();
  }

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "ebook",
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

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "uid": uid,
      "cid": cateVal,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().ebookList),
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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  updateEbookHit(id) {
    Map _map = {};
    _map.addAll({
      "id": id,
    });
    var body = json.encode(_map);
    return postEbookHit(http.Client(), body, _map);
  }

  Future<List<AllList>> postEbookHit(
      http.Client client, jsonMap, Map map) async {
    await client.post(Uri.parse(Info().ebookDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 2;

    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "วารสาร",
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
              color: Color(0xFFFFFFFF),
              padding: EdgeInsets.only(left: 8, right: 8),
              child: (data != null && data.length != 0)
                  ? GridView.count(
                      childAspectRatio: (itemWidth / itemHeight),
                      crossAxisCount: 2,
                      children: List.generate(data.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            _launchInBrowser(data[index]["link"]);
                            updateEbookHit(data[index]["id"]);
                          },
                          child: Center(
                            child: Stack(
                              children: [
                                if (data[index]["mod"] == "1")
                                  Positioned.fill(
                                    bottom: -110,
                                    child: Image.asset(
                                      'assets/images/ebook_bar1.png',
                                    ),
                                  ),
                                if (data[index]["mod"] == "2")
                                  Positioned.fill(
                                    bottom: -110,
                                    child: Image.asset(
                                      'assets/images/ebook_bar2.png',
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.only(top: 8, bottom: 8),
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: ClipRRect(
                                                child: Image.network(
                                                  data[index]["display_image"],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 16),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.all(6),
                                          child: Column(
                                            children: [
                                              Text(
                                                data[index]["subject"],
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
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
