import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class FooterView extends StatefulWidget {
  @override
  _FooterViewState createState() => _FooterViewState();
}

class _FooterViewState extends State<FooterView> {
  var faceLink = "";
  var lineLink = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSiteDetail();
  }

  getSiteDetail() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postSiteDetail(http.Client(), body, _map);
  }

  Future<List<AllList>> postSiteDetail(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().siteDetail),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      faceLink = rs["faceLink"].toString();
      lineLink = rs["lineLink"].toString();
    });
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
    return Container(
      padding: EdgeInsets.only(bottom: 36, top: 8),
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "คุยสดกับเจ้าหน้าที่",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (faceLink != "") {
                      _launchInBrowser(faceLink);
                    } else {
                      Toast.show("ไม่มีข้อมูล", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }
                  },
                  child: Image.asset(
                    'assets/images/main/face.png',
                  ),
                ),
              ),
              Expanded(
                // flex: 1,
                child: Container(),
              ),
              // Expanded(
              //   child: GestureDetector(
              //     onTap: () {
              //       if (lineLink != "") {
              //         _launchInBrowser(lineLink);
              //       } else {
              //         Toast.show("ไม่มีข้อมูล", context,
              //             duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              //       }
              //     },
              //     child: Image.asset(
              //       'assets/images/main/line.png',
              //     ),
              //   ),
              // ),
            ],
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Copyright©2021.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'suratcity.go.th',
                  style: TextStyle(
                    color: Color(0xFF8C1F78),
                    fontSize: 11,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchInBrowser("https://suratcity.go.th");
                    },
                ),
                TextSpan(
                  text: ' All rights reserved. Powered by ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'CityVariety Corporation.',
                  style: TextStyle(
                    color: Color(0xFF00C3EB),
                    fontSize: 11,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchInBrowser("http://cityvariety.co.th");
                    },
                ),
              ],
            ),
          )

          /*TextSpan(
            children: [
              Text(
                " CityVariety Corporation.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }
}
