import 'dart:convert';

import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/AppBarView.dart';
import 'package:cvapp/view/PageSubView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'GreenMarketDetailView.dart';

var data;

//dropdown
var arrMap;
String cateVal = "";
Map<int, String> dataCateMap = {0: "หมวดหมู่"};
//dropdown

class GreenMarketListView extends StatefulWidget {
  GreenMarketListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _GreenMarketListViewState createState() => _GreenMarketListViewState();
}

class _GreenMarketListViewState extends State<GreenMarketListView> {
  var userFullname;
  var uid;

  final keyword = TextEditingController();

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
  }

  @override
  void dispose() {
    super.dispose();
    dataCateMap = {0: "หมวดหมู่"};
    arrMap = null;
    if (data != null && data.length != 0) {
      data = null;
    }
  }

  //dropdown
  getCateList() {
    Map _map = {};
    _map.addAll({
      "cmd": "market",
    });
    var body = json.encode(_map);
    return postCateData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCateData(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().cateListPity),
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

    getNewsList();

    return parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
  }

  String dropdownValue2 = (cateVal != "") ? cateVal : "0";

  Widget dropDownCate() {
    return (arrMap != null && arrMap.length != 0)
        ? Container(
            height: 46,
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(9.0),
              ),
            ),
            child: DropdownButton<String>(
              value: dropdownValue2,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_outlined),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Color(0xFF686868)),
              underline: Container(
                height: 1,
                color: Colors.transparent,
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
            ),
          )
        : Container();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "100",
      "isListView": "1",
      "cid": cateVal,
      "keyword": keyword.text,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().marketList),
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

    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.4;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBarView(
        title: "ตลาดชาวบ้าน",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 8),
                    margin: EdgeInsets.only(right: 8),
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(9.0),
                      ),
                    ),
                    child: TextField(
                      controller: keyword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: 'พิมพ์คำค้นหา เช่น ชื่อสินค้า',
                        hintStyle: TextStyle(
                          fontSize: 12,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (FocusScope.of(context).isFirstFocus) {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            }
                            getNewsList();
                          },
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF1D1D1D),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: dropDownCate(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: (data != null && data.length != 0)
                  ? GridView.count(
                      // childAspectRatio: (itemWidth / itemHeight),
                      childAspectRatio: 0.6,
                      crossAxisCount: 2,
                      children: List.generate(data.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GreenMarketDetailView(
                                  topicID: data[index]["id"],
                                  title: "ตลาดชาวบ้าน",
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Stack(
                              children: [
                                if (data[index]["mod"] == "1")
                                  Positioned.fill(
                                    bottom: 0,
                                    child: Image.asset(
                                      'assets/images/ebook_bar1.png',
                                    ),
                                  ),
                                if (data[index]["mod"] == "2")
                                  Positioned.fill(
                                    bottom: 0,
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
                                        flex: 4,
                                        child: (data[index]["id"] != "")
                                            ? Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.0,
                                                  ),
                                                  image: DecorationImage(
                                                    image: (data[index][
                                                                "display_image"] !=
                                                            "")
                                                        ? NetworkImage(data[
                                                                    index][
                                                                "display_image"]
                                                            .trim())
                                                        : AssetImage(
                                                            'assets/images/main/test.png'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          margin: EdgeInsets.only(top: 26),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          alignment: Alignment.topLeft,
                                          padding: EdgeInsets.only(top: 4),
                                          child: (data[index]["id"] != "")
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        data[index]
                                                            ["productName"],
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        data[index]
                                                            ["productDetail"],
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 4),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/main/shop.png',
                                                            width: 10,
                                                            color: Color(
                                                                0xFF8C1F78),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 6),
                                                              child: Text(
                                                                data[index][
                                                                    "shopName"],
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF686868),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 4),
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/main/pin.png',
                                                            width: 10,
                                                            color: Color(
                                                                0xFF8C1F78),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 6),
                                                              child: Text(
                                                                data[index][
                                                                    "shopAddress"],
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(
                                                                      0xFF686868),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (data[index]["hits"] !=
                                                        "")
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            top: 8),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                child:
                                                                    Container()),
                                                            Image.asset(
                                                              'assets/images/main/hit.png',
                                                              width: 12,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 4),
                                                              child: Text(
                                                                data[index]
                                                                    ["hits"],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  color: Color(
                                                                      0xFF1D1D1D),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  ],
                                                )
                                              : Container(),
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
    );
  }
}
