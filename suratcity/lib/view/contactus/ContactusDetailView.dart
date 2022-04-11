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

class ContactusDetailView extends StatefulWidget {
  ContactusDetailView({Key key, this.topicID, this.reply}) : super(key: key);
  final String topicID;
  final String reply;

  @override
  _ContactusDetailViewState createState() => _ContactusDetailViewState();
}

class _ContactusDetailViewState extends State<ContactusDetailView> {
  var subject = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  BoxDecoration boxWhite() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(9.0),
      ),
      border: Border.all(
        color: Colors.blue,
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
        title: "ติดตามเรื่องที่ติดต่อ",
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
                //title
                Container(
                  child: Text(
                    "ข้อความตอบกลับ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                //reply
                Container(
                  margin: EdgeInsets.only(top: 16),
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: boxWhite(),
                  child: Text(
                    (widget.reply != "") ? widget.reply : "ไม่พบการตอบกลับ",
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
