import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'PhoneDetailView.dart';
import 'PhoneListView.dart';

var data;

class PhoneCateListView extends StatefulWidget {
  PhoneCateListView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _PhoneCateListViewState createState() => _PhoneCateListViewState();
}

class _PhoneCateListViewState extends State<PhoneCateListView> {
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
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "uid": uid,
      "rows": 500,
      "cid": "2",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().callList),
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

  getDataDetail() {
    if (keyword.text != "") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneListView(
            isHaveArrow: "1",
            keyword: keyword.text,
          ),
        ),
      );
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "หมายเลขโทรศัพท์ฉุกเฉิน",
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
                  child: TextField(
                    controller: keyword,
                    decoration: InputDecoration(
                      hintText: 'พิมพ์คำค้นหา เช่น ชื่อ-นามสกุล',
                      hintStyle: TextStyle(
                        fontSize: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          getDataDetail();
                        },
                        icon: Icon(
                          Icons.search,
                          color: Color(0xFF8C1F78),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _makePhoneCall('tel:199');
            },
            child: Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/call.png',
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: EdgeInsets.only(left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "แจ้งเหตุด่วน",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Kanit',
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "สายด่วน",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Kanit',
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 0),
                                child: Text(
                                  "เทศบาลนครสุราษฎร์ธานี",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Kanit',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "199",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.only(left: 16, right: 16),
              child: (data != null && data.length != 0)
                  ? GroupedListView<dynamic, String>(
                      elements: data,
                      sort: false,
                      groupBy: (element) => element['session_header'],
                      useStickyGroupSeparators: true,
                      groupSeparatorBuilder: (String value) => Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Kanit',
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
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
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
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      /*CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          element["display_image"],
                                        ),
                                      ),*/
                                      Icon(
                                        Icons.phone,
                                        color: Color(0xFF8C1F78),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                element["subject"],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Kanit',
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                element["tel"],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontFamily: 'Kanit',
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider(),
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
            ),
          ),
        ],
      ),
    ));
  }
}
