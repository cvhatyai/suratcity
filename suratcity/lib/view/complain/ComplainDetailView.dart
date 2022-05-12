import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../AppBarView.dart';

var data;
List<String> imgList = [];
List<String> imgList2 = [];
List<String> imgList3 = [];
List<String> imgList4 = [];

class ComplainDetailView extends StatefulWidget {
  ComplainDetailView({Key key, this.topicID, this.title = "", this.isShow = ""})
      : super(key: key);
  final String topicID;
  final String title;
  final String isShow;

  @override
  _ComplainDetailViewState createState() => _ComplainDetailViewState();
}

class _ComplainDetailViewState extends State<ComplainDetailView> {
  var subject = "";
  var name = "";
  var create_date = "";
  var near_location = "";
  var phone = "";
  var description = "";
  var type_name = "";
  var status = "";
  var reply_by_admin = "";
  var reply_finish = "";

  var latitude = "";
  var longtitude = "";
  int imgcount = 0;
  int imgcount2 = 0;
  int imgcount3 = 0;
  int imgcount4 = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetail();
  }

  getDetail() async {
    Map _map = {};
    _map.addAll({
      "id": widget.topicID,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postDetail(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().informDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    data = json.decode(response.body);

    setState(() {
      subject = data['subject'].toString();
      name = data['name'].toString();
      create_date = data['create_date'].toString();
      near_location = data['near_location'].toString();
      phone = data['phone'].toString();
      description = data['description'].toString();
      type_name = data['type_name'].toString();
      status = data['status'].toString();
      reply_by_admin = data['reply_by_admin'].toString();
      reply_finish = data['reply_finish'].toString();

      latitude = data['latitude'].toString();
      longtitude = data['longtitude'].toString();

      imgcount = data['imgcount'];
      if (imgcount > 0) {
        imgList.clear();
        var tmp = data['img'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList.addAll(tmp.split(","));
      }

      imgcount2 = data['imgcount2'];
      if (imgcount2 > 0) {
        imgList2.clear();
        var tmp = data['img2'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList2.addAll(tmp.split(","));
      }

      imgcount3 = data['imgcount3'];
      if (imgcount3 > 0) {
        imgList3.clear();
        var tmp = data['img3'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList3.addAll(tmp.split(","));
      }

      imgcount4 = data['imgcount4'];
      if (imgcount4 > 0) {
        imgList4.clear();
        var tmp = data['img4'].toString().replaceAll("[", "");
        tmp = tmp.replaceAll("]", "");
        imgList4.addAll(tmp.split(","));
      }
    });
    EasyLoading.dismiss();
  }

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        color: Color(0xFF8C1F78),
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
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: (widget.title != "") ? widget.title : "ติดตามเรื่องร้องเรียน",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("วันที่แจ้ง")),
                            Expanded(child: Text(create_date)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                if (widget.isShow != "1")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text("ชื่อ-สกุล")),
                              Expanded(child: Text(name)),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("เรื่อง")),
                            Expanded(child: Text(subject)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //สถานที่เกิดเหตุใกล้เคียง
                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text("สถานที่เกิดเหตุใกล้เคียง")),
                            Expanded(child: Text(near_location)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                //แผนที่
                if (latitude != "")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 32),
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: GoogleMap(
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(double.parse(latitude),
                                  double.parse(longtitude)),
                              zoom: 18,
                            ),
                            key: ValueKey('uniqueey'),
                            onMapCreated: _onMapCreated,
                            markers: {
                              Marker(
                                  markerId: MarkerId('anyUniqueId'),
                                  position: LatLng(double.parse(latitude),
                                      double.parse(longtitude)),
                                  infoWindow:
                                      InfoWindow(title: 'Some Location'))
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF8C1F78)),
                            ),
                            onPressed: () {
                              var urlMap =
                                  "https://www.google.com/maps/dir/?api=1&destination=" +
                                      latitude.toString() +
                                      "," +
                                      longtitude.toString();
                              _launchInBrowser(urlMap);
                            },
                            child: Text('นำทาง'),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูป
                if (imgcount > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                if (widget.isShow != "1")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text("เบอร์โทรศัพท์ติดต่อ")),
                              Expanded(child: Text(phone)),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                if (widget.isShow != "1")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text("รายละเอียด"),
                                width: MediaQuery.of(context).size.width,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 16),
                                child: Text(description),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                if (widget.isShow != "1")
                  Container(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                  child:
                                      Text("ประเภทของการแจ้งเรื่องร้องเรียน")),
                              Expanded(child: Text(type_name)),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text("สถานะการแจ้งเรื่องร้องเรียน")),
                            Expanded(child: Text(status)),
                          ],
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),

                if (widget.isShow != "1")
                  if (reply_by_admin != "")
                    Container(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text("รายละเอียดการดำเนินการ")),
                                Expanded(child: Text(reply_by_admin)),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),

                if (widget.isShow != "1")
                  if (reply_finish != "")
                    Container(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(
                                        "รายละเอียดการดำเนินการเรียบร้อยแล้ว")),
                                Expanded(child: Text(reply_finish)),
                              ],
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),

                //รูปก่อน
                if (imgcount3 > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพก่อนการดำเนินการ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount3; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList3[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList3[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ),

                //รูปหลัง
                if (imgcount4 > 0)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text("รูปภาพหลังการดำเนินการ"),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(bottom: 16),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var i = 0; i < imgcount4; i++)
                                GestureDetector(
                                  onTap: () {
                                    _launchInBrowser(imgList4[i].trim());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 2),
                                    color: Colors.black,
                                    child: Image.network(
                                      imgList4[i].trim(),
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
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
          ),
        ),
      ),
    ));
  }
}
