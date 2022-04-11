import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/phone/PhoneCateListView.dart';
import 'package:url_launcher/url_launcher.dart';

var data;

class SuggustViewOld extends StatefulWidget {
  @override
  _SuggustViewOldState createState() => _SuggustViewOldState();
}

class _SuggustViewOldState extends State<SuggustViewOld> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "4",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().linkProvinceList),
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 6;
    final double itemWidth = size.width / 2;
    return Container(
      color: Color(0xFFf5f6fa),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerLeft,
            child: Text(
              "แนะนำสำหรับคุณ",
              style: TextStyle(color: Color(0xFF4283C4), fontSize: 18),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.96,
            padding: EdgeInsets.all(4),
            child: (data != null && data.length != 0)
                ? GridView.count(
                    childAspectRatio: (itemWidth / itemHeight),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(data.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (data[index]["subject"] == "แจ้งเหตุด่วน") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneCateListView(
                                  isHaveArrow: "1",
                                ),
                              ),
                            );
                          } else {
                            if (data[index]["link"] != "") {
                              _launchInBrowser(data[index]["link"]);
                            }
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(4),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: ClipRRect(
                            child: Image.network(
                              data[index]["display_image"],
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
          ),
        ],
      ),
    );
  }
}
