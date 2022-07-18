import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

var data;
List<String> imgList = [];
var fileList;

class CalendarTravelDetailView extends StatefulWidget {
  CalendarTravelDetailView({Key key, this.topicID}) : super(key: key);
  final String topicID;

  @override
  _CalendarTravelDetailViewState createState() => _CalendarTravelDetailViewState();
}

class _CalendarTravelDetailViewState extends State<CalendarTravelDetailView> {
  var userFullname;
  var uid;

  var subject = "";
  var from = "";
  var location = "";
  var cost = "";
  var detail = "";
  int imgcount = 0;
  int filecount = 0;
  var event_date = "";
  var img = "";
  var display_image = Info().baseUrl + "images/nopic.png";
  int _currentPage = 0;

  @override
  void dispose() {
    setState(() {
      data.clear();
      imgList.clear();
      fileList.clear();
    });
    super.dispose();
  }

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
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().travelEventsDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    imgList.clear();
    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      from = data['from'].toString();
      location = data['location'].toString();
      cost = data['cost'].toString();
      detail = data['description'].toString();
      event_date = data['event_date'].toString();
      display_image = data['display_image'].toString();

      imgcount = data['imgcount'];

      //imgList.add(display_image);
      if (imgcount > 0) {
        imgList.clear();
        var tmp = data['img'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList.addAll(tmp.split(","));
      }
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
        title: "กิจกรรมที่กำลังจะมาถึง",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //หัวข้อ
                Text(
                  subject,
                  style: TextStyle(
                      color: Color(0xFF8C1F78),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                //วันที่จัดกิจกรรม
                if (event_date != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("วันที่จัดกิจกรรม"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(event_date),
                        ),
                      ],
                    ),
                  ),
                //ผู้จัดกิจกรรม
                if (from != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("ผู้จัดกิจกรรม"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(from),
                        ),
                      ],
                    ),
                  ),
                //สถานที่จัด
                if (location != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("สถานที่จัด"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(location),
                        ),
                      ],
                    ),
                  ),
                //ค่าใช้จ่ายในการร่วมงาน
                if (cost != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text("ค่าใช้จ่ายในการร่วมงาน"),
                        ),
                        Expanded(
                          child: Text(cost),
                        ),
                      ],
                    ),
                  ),
                //รายละเอียด
                if (detail != "")
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text("รายละเอียด"),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(detail),
                        ),
                      ],
                    ),
                  ),
                //ภาพ
                if (imgList.length > 0)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.3,
                            viewportFraction: 1,
                            enableInfiniteScroll: false,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentPage = index;
                              });
                            }),
                        items: imgList.map((image) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                    ),
                                    child: Image.network(
                                      image.trim(),
                                    ),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(1),
                                  ),
                                  /*Text(
                                    imgList.indexOf(image).toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),*/
                                ],
                              );
                            },
                          );
                        }).toList(),
                      ),
                      if (imgList.length > 1)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            //width: MediaQuery.of(context).size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imgList.map((image) {
                                int index = imgList.indexOf(image);
                                return theIndicator(_currentPage, index);
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                //ไฟล์
                if (filecount > 0)
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xFF8C1F78),
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
                              Divider(),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
