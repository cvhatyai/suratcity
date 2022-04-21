import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';

class MarqueeView extends StatefulWidget {
  @override
  _MarqueeViewState createState() => _MarqueeViewState();
}

class _MarqueeViewState extends State<MarqueeView> {
  String msg = "ยินดีต้อนรับ";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessageList();
  }

  getMessageList() async {
    Map _map = {};
    _map.addAll({});
    var body = json.encode(_map);
    return postMessageList(http.Client(), body, _map);
  }

  Future<List<AllList>> postMessageList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().messageList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    setState(() {
      msg = rs["msg"].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main/marquee.png'),
          fit: BoxFit.cover,
          alignment: FractionalOffset.topCenter,
        ),
      ),
      child: Row(
        children: [
          Container(width: 50),
          Expanded(
            child: Marquee(
              text: msg,
              style: TextStyle(height: 1.5),
              blankSpace: 280,
            ),
          ),
          Container(width: 10),
        ],
      ),
    );
  }
}
