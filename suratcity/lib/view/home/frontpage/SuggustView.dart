import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/phone/PhoneCateListView.dart';
import 'package:url_launcher/url_launcher.dart';

var data;
List<String> modList = [];
int lenBox = 0;

class SuggustView extends StatefulWidget {
  @override
  _SuggustViewState createState() => _SuggustViewState();
}

class _SuggustViewState extends State<SuggustView> {
  int _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getNewsList();
  }

  getNewsList() async {
    Map _map = {};
    _map.addAll({
      "rows": "12",
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

    if (data != null && data.length != 0) {
      modList = [];
      var modLen = (data.length / 4).ceil();
      print("modLen : " + modLen.toString());

      var tmp = 0;
      var tmpData = data.length;
      for (int i = 0; i < modLen; i++) {
        tmp = tmpData;
        if (tmp >= 4) {
          modList.add("4");
          tmpData = tmpData - 4;
        } else {
          modList.add(tmp.toString());
        }
      }
      lenBox = int.parse(modList[0]);
      print("modList" + modList.toString());
      //print("data" + data.toString());
      //print("datalen" + data.length.toString());
    }

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

  Widget theIndicator(_currentPage, index) {
    if (_currentPage == index) {
      return Container(
        width: 24.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(9.0),
          ),
          color: Color(0xFF388DFC),
        ),
      );
    } else {
      return Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFB4B4B4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3.5;
    final double itemWidth = size.width / 2;
    return Container(
      color: Color(0xFFf5f6fa),
      child: Column(
        children: [
          Container(
              margin: EdgeInsets.only(top: 12, left: 12),
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/images/main/travel1.png',
                  fit: BoxFit.cover, height: 30)),
          Container(
            margin: EdgeInsets.only(top: 8),
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.96,
            padding: EdgeInsets.all(2),
            child: (data != null && data.length != 0)
                ? Column(
                    children: [
                      Container(
                        child: CarouselSlider(
                          options: CarouselOptions(
                              height: itemHeight * 2,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPage = index;
                                  lenBox = int.parse(modList[_currentPage]);
                                });
                              }),
                          items: modList.map((modeName) {
                            return GridView.count(
                              childAspectRatio: (itemWidth / itemHeight),
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(lenBox, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    var subject = _currentPage == 1
                                        ? data[index + 4]["subject"]
                                        : _currentPage == 2
                                            ? data[index + 8]["subject"]
                                            : data[index]["subject"];
                                    if (subject == "แจ้งเหตุด่วน") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhoneCateListView(
                                            isHaveArrow: "1",
                                          ),
                                        ),
                                      );
                                    } else {
                                      var link = _currentPage == 1
                                          ? data[index + 4]["link"]
                                          : _currentPage == 2
                                              ? data[index + 8]["link"]
                                              : data[index]["link"];
                                      if (link != "") {
                                        _launchInBrowser(link);
                                      }
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0)),
                                      color: Colors.black,
                                    ),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0)),
                                          child: Image.network(
                                            _currentPage == 1
                                                ? data[index + 4]
                                                    ["display_image"]
                                                : _currentPage == 2
                                                    ? data[index + 8]
                                                        ["display_image"]
                                                    : data[index]
                                                        ["display_image"],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10.0),
                                                  bottomRight:
                                                      Radius.circular(10.0)),
                                              color: Colors.black,
                                            ),
                                            height: 40,
                                            width: double.infinity,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, right: 4.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  '${data[index]["subject"]}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            );
                          }).toList(),
                        ),
                      ),
                      if (modList.length > 1)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: modList.map((modeName) {
                              int index = modList.indexOf(modeName);
                              return theIndicator(_currentPage, index);
                            }).toList(),
                          ),
                        ),
                    ],
                  )
                : Container(
                    child: Center(child: Text("ไม่มีข้อมูล")),
                  ),
          ),
        ],
      ),
    );
  }
}
