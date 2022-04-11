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
var fileList;

class LawDetailView extends StatefulWidget {
  LawDetailView({Key key, this.topicID}) : super(key: key);
  final String topicID;

  @override
  _LawDetailViewState createState() => _LawDetailViewState();
}

class _LawDetailViewState extends State<LawDetailView> {
  var userFullname;
  var uid;

  var subject = "";
  var detail = "";
  int imgcount = 0;
  int filecount = 0;
  var url = "";
  var create_date = "";
  var img = "";
  var display_image = Info().baseUrl + "images/nopic.png";
  int _currentPage = 0;

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
    getNewsDetail();
  }

  getNewsDetail() async {
    Map _map = {};
    _map.addAll({
      "id": widget.topicID,
      "cmd": "news_rule",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().newsDocumentDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      detail = data['description'].toString();
      if (data['url'].toString() != "null") {
        url = data['url'].toString();
      }
      display_image = data['display_image'].toString();
      create_date = data['create_date'].toString();
      imgcount = data['imgcount'];

      filecount = data['filecount'];
      if (filecount > 0) {
        fileList = [];
        fileList.addAll(json.decode(json.encode(data['file'])));
      }
    });
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

  BoxDecoration boxWhite() {
    return BoxDecoration(
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
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    );
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
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ระเบียบข้อกฏหมาย/ข้อบัญญัติ",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: [
                //หัวข้อ 1 มี bar
                /*ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 80,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xFF2CC1A0),
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: Color(0xFF55C3FF),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),*/
                //หัวข้อ 2 ไม่มี bar
                Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  //color: Color(0xFF2CC1A0),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: Color(0xFF55C3FF),
                      fontSize: 18,
                    ),
                  ),
                ),
                if (filecount > 0)
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 16),
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blue,
                    child: Text(
                      "เอกสารดาวน์โหลด",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (filecount > 0)
                  Column(
                    children: [
                      for (int f = 0; f < filecount; f++)
                        GestureDetector(
                          onTap: () {
                            _launchInBrowser(fileList[f]["filepath"]);
                          },
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 16, right: 16),
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, top: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        fileList[f]["filename"],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      fileList[f]["filesizes"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                indent: 24,
                                endIndent: 24,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                //รายละเอียด
                if (detail != "")
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(16),
                    child: Text(detail),
                  ),
                //เวลา
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_sharp,
                        color: Colors.blue,
                        size: 22,
                      ),
                      Text(
                        create_date,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                //กดเพื่อรับชมวิดีโอ
                if (url != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: RaisedButton(
                      onPressed: () {
                        _launchInBrowser(url);
                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      child: Container(
                        width: 250,
                        height: 40,
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            gradient: new LinearGradient(
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.blueAccent,
                              ],
                            )),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "กดเพื่อรับชมวิดีโอ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
