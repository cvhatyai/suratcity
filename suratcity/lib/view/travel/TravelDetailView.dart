import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:share/share.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'TravelCommentListView.dart';

var data;
List<String> imgList = [];
var fileList;

class TravelDetailView extends StatefulWidget {
  TravelDetailView({Key key, this.topicID, this.title, this.tid})
      : super(key: key);
  final String topicID;
  final String title;
  final String tid;

  @override
  _TravelDetailViewState createState() => _TravelDetailViewState();
}

class _TravelDetailViewState extends State<TravelDetailView> {
  var userFullname;
  var uid;
  var isLoved = "";
  var isFav = "";
  var favCount = 0;

  var favFnName = "";
  var fnName = Info().travelDetail;
  List<String> arrFav = [];

  var subject = "";
  var link = "";
  var lat = "";
  var lng = "";
  var comment = "";
  var love = "";
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
    getNewsDetail();

    if (widget.tid == "1") {
      fnName = Info().travelDetail;
      favFnName = "travelList";
    } else if (widget.tid == "2") {
      fnName = Info().restDetail;
      favFnName = "restList";
    } else if (widget.tid == "3") {
      fnName = Info().eatDetail;
      favFnName = "eatList";
    } else if (widget.tid == "4") {
      fnName = Info().shopDetail;
      favFnName = "shopList";
    }

    initLove(widget.topicID, "travel");
    var tmpContain = widget.topicID + "_" + favFnName;
    print("tmpContain" + tmpContain);
    initFav(tmpContain);
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
    final response = await client.post(Uri.parse(fnName),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    imgList.clear();
    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      detail = data['description'].toString();
      link = data['link'].toString();

      if (data['lat'].toString() != "null") {
        lat = data['lat'].toString();
        lng = data['lng'].toString();
      }

      if (data['url'].toString() != "null") {
        url = data['url'].toString();
      }
      display_image = data['display_image'].toString();
      comment = data['comment'].toString();
      love = data['love'].toString();
      create_date = data['create_date'].toString();
      imgcount = data['imgcount'];
      imgList.add(display_image);
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

  //updateLove
  updateLove(id) async {
    Map _map = {};
    _map.addAll({
      "id": id,
      "table": "travel_information",
    });
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    var fnName = Info().addLove;
    if (isLoved == "1") {
      fnName = Info().removeLove;
    } else {
      fnName = Info().addLove;
    }
    final response = await http.Client().post(Uri.parse(fnName),
        headers: {"Content-Type": "application/json"}, body: body);

    data = json.decode(response.body);
    var status = data['status'].toString();
    var tmpLove = data['love'].toString();
    if (status == "success") {
      updatePrefLove(widget.topicID, "travel");
      setState(() {
        love = tmpLove;
      });
      print("love : " + love);
    }
  }

  initLove(id, cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString(id + "_" + cmd).toString() != "null") {
        isLoved = prefs.getString(id + "_" + cmd).toString();
      }
    });
  }

  updatePrefLove(id, cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isLoved == "1") {
      prefs.remove(id + "_" + cmd);
      setState(() {
        isLoved = "";
      });
    } else {
      prefs.setString(id + "_" + cmd, "1");
      setState(() {
        isLoved = "1";
      });
    }
  }

  //updateFave
  initFav(cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    arrFav = prefs.getStringList("favList");
    setState(() {
      if (arrFav != null) {
        favCount = arrFav.length;
        if (arrFav.contains(cmd)) {
          isFav = "1";
        } else {
          isFav = "";
        }
      }
    });
  }

  updateFav(id, cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var favTmp = id + "_" + cmd;
    if (arrFav == null) {
      arrFav = [];
      arrFav.add(favTmp);
      prefs.setStringList("favList", arrFav);
    } else {
      if (arrFav.contains(favTmp)) {
        arrFav.removeWhere((element) => element == favTmp);
        prefs.setStringList("favList", arrFav);
      } else {
        arrFav.add(favTmp);
        prefs.setStringList("favList", arrFav);
      }
    }
    initFav(favTmp);
  }

  clearFavList() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("favList");
    arrFav = prefs.getStringList("favList");
    print("clear");
    print(arrFav);*/
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: widget.title,
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: [
                //ภาพ
                if (imgList.length == 0)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(
                          Radius.circular(9.0),
                        ),
                      ),
                      child: Image.network(
                        display_image,
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                    ),
                  ),
                if (imgList.length > 0)
                  Stack(
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
                                  GestureDetector(
                                    onTap: () {
                                      _launchInBrowser(image.trim());
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.97,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(9.0),
                                        ),
                                      ),
                                      child: Image.network(
                                        image.trim(),
                                      ),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(1),
                                    ),
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
                            width: MediaQuery.of(context).size.width,
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
                //หัวข้อ 1 มี bar
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 80,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      clearFavList();
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xFF2DA3FF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subject,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  subject,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //หัวข้อ 2 ไม่มี bar
                /*Container(
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
                    ),*/

                //activityTab
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          //like
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                updateLove(widget.topicID);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            (isLoved != "")
                                                ? 'assets/images/travel/love_selected.png'
                                                : 'assets/images/travel/love.png',
                                            height: 24,
                                          ),
                                          padding: EdgeInsets.all(8),
                                        ),
                                        if (love != "")
                                          Positioned(
                                            right: 0,
                                            top: 4,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                color: Color(0xFF00B9FF),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  love,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "ถูกใจ",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //comment
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TravelCommentListView(
                                      topicID: widget.topicID,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    child: Stack(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/travel/chat.png',
                                            height: 24,
                                          ),
                                          padding: EdgeInsets.all(8),
                                        ),
                                        if (comment != "")
                                          Positioned(
                                            right: 0,
                                            top: 4,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(6),
                                                ),
                                                color: Color(0xFF00B9FF),
                                              ),
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  comment,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "ความคิดเห็น",
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //navigator
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (lat != "") {
                                  var urlMap =
                                      "https://www.google.com/maps/dir/?api=1&destination=" +
                                          lat.toString() +
                                          "," +
                                          lng.toString();
                                  _launchInBrowser(urlMap);
                                } else {
                                  Toast.show("ไม่มีข้อมูล", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Image.asset(
                                        'assets/images/travel/nav.png',
                                        height: 24,
                                      ),
                                      padding: EdgeInsets.all(8),
                                    ),
                                    Text(
                                      "นำทาง",
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //share
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                //_launchInBrowser(link);
                                Share.share(link, subject: subject);
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Image.asset(
                                        'assets/images/travel/share.png',
                                        height: 24,
                                      ),
                                      padding: EdgeInsets.all(8),
                                    ),
                                    Text(
                                      "แชร์",
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          //fav
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                updateFav(widget.topicID, favFnName);
                              },
                              child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Stack(
                                        children: [
                                          Container(
                                            child: Image.asset(
                                              (isFav != "")
                                                  ? 'assets/images/travel/fav_selected.png'
                                                  : 'assets/images/travel/fav.png',
                                              height: 24,
                                            ),
                                            padding: EdgeInsets.all(8),
                                          ),
                                          if (favCount != 0)
                                            Positioned(
                                              right: 0,
                                              top: 4,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                                  color: Color(0xFF00B9FF),
                                                ),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    favCount.toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "บันทึก",
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                    ],
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
