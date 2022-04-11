import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Info.dart';

class InitLove extends StatefulWidget {
  InitLove({Key key, this.id, this.cmd, this.loveCount}) : super(key: key);
  String id;
  String cmd;
  String loveCount;

  @override
  _InitLoveState createState() => _InitLoveState();
}

class _InitLoveState extends State<InitLove> {
  var isLoved = "";
  var love = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initLove(widget.id, widget.cmd);
    love =  widget.loveCount;
  }

  @override
  void dispose() {
    super.dispose();
  }

  initLove(id, cmd) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString(id + "_" + cmd).toString() != "null") {
        isLoved = prefs.getString(id + "_" + cmd).toString();
      }
    });
  }

  updatePrefLove(id, cmd, tmpLove) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isLoved == "1") {
      prefs.remove(id + "_" + cmd);
      setState(() {
        isLoved = "";
        love = tmpLove;
      });
    } else {
      prefs.setString(id + "_" + cmd, "1");
      setState(() {
        isLoved = "1";
        love = tmpLove;
      });
    }
  }

  //updateLove
  updateLove(id, cmd) async {
    Map _map = {};
    _map.addAll({
      "id": id,
      "table": "travel_information",
    });
    var body = json.encode(_map);
    var fnName = Info().addLove;
    if (isLoved == "1") {
      fnName = Info().removeLove;
    } else {
      fnName = Info().addLove;
    }
    final response = await http.Client().post(Uri.parse(fnName),
        headers: {"Content-Type": "application/json"}, body: body);

    var data;
    data = json.decode(response.body);
    var status = data['status'].toString();
    var tmpLove = data['love'].toString();
    if (status == "success") {
      updatePrefLove(id, cmd, tmpLove);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        updateLove(widget.id, widget.cmd);
      },
      child: Container(
        child: Row(
          children: [
            Image.asset(
              (isLoved == "1")
                  ? 'assets/images/travel/love_selected.png'
                  : 'assets/images/travel/love.png',
              height: 16,
            ),
            if (love != "")
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Text(
                  love,
                ),
              ),
          ],
        ),
      ),
    );
    return Text("isLoved" + isLoved);
  }
}
