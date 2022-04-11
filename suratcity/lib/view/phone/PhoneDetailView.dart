import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';
import 'PhoneEditView.dart';

var data;

class PhoneDetailView extends StatefulWidget {
  PhoneDetailView({Key key, this.isHaveArrow = "", this.id = ""})
      : super(key: key);
  final String isHaveArrow;
  final String id;

  @override
  _PhoneDetailViewState createState() => _PhoneDetailViewState();
}

class _PhoneDetailViewState extends State<PhoneDetailView> {
  var userFullname;
  var uid;
  var isFav = "";

  var subject = "";
  var position = "";
  var tel = "";
  var display_image = Info().baseUrl + "images/app/nopic.png";
  var last_update = "";

  List<String> arrFav = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetail();
    var tmpContain = widget.id + "_callList";
    initFav(tmpContain);
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
      "id": widget.id,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().callDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      position = data['position'].toString();
      tel = data['tel'].toString();
      display_image = data['display_image'].toString();
      last_update = data['last_update'].toString();
    });
    EasyLoading.dismiss();
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  initFav(cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    arrFav = prefs.getStringList("favList");
    setState(() {
      if (arrFav != null) {
        //favCount = arrFav.length;
        if (arrFav.contains(cmd)) {
          isFav = "1";
        } else {
          isFav = "";
        }
      }

      print(arrFav);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "เบอร์โทรสำคัญ",
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //แจ้งแก้ไขข้อมูล
                Container(
                  margin: EdgeInsets.only(right: 8),
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneEditView(
                              isHaveArrow: "1",
                              id: widget.id,
                              subject: subject,
                            ),
                          ),
                        );
                      },
                      child: Text("แจ้งแก้ไขข้อมูล")),
                ),

                Container(
                  child: Stack(
                    children: [
                      //fav
                      Container(
                        margin: EdgeInsets.only(right: 8, top: 16),
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            updateFav(widget.id, "callList");
                          },
                          child: Container(
                            child: Image.asset(
                              (isFav != "")
                                  ? 'assets/images/travel/fav_selected.png'
                                  : 'assets/images/travel/fav.png',
                              height: 24,
                            ),
                            padding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //detail
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                        display_image,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 8, bottom: 8, left: 8, right: 32),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          subject,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Divider(),
                                        if (tel != "")
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  child: Text("โทร : " + tel),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _makePhoneCall('tel:$tel');
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 8),
                                                  child: Icon(Icons.phone),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //datetime
                            Container(
                              margin: EdgeInsets.all(16),
                              child: Text(last_update),
                            ),
                          ],
                        ),
                      ),
                    ],
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
