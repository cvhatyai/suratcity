import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

import '../AppBarView.dart';
import '../FrontPageView.dart';

var data;

class PollView extends StatefulWidget {
  PollView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _PollViewState createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  var userFullname;
  var uid;
  var isVoted;

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
      isVoted = prefs.getString('isVoted').toString();
    });
  }

  insertData(msg, comment) async {
    var rating = "5";
    if (msg == "ยอดเยี่ยม") {
      rating = "5";
    } else if (msg == "ดี") {
      rating = "4";
    } else if (msg == "พอสมควร") {
      rating = "3";
    } else if (msg == "แย่") {
      rating = "2";
    } else if (msg == "แย่มาก") {
      rating = "1";
    }
    Map _map = {};
    _map.addAll({
      "uid": uid,
      "rating": rating,
      "description": comment,
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().pollVote),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  updatePref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('isVoted', "1");
  }

  List<AllList> parseNewsList(String responseBody) {
    var rs = json.decode(responseBody);
    updatePref();
    Toast.show(rs["msg"], context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    EasyLoading.dismiss();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => FrontPageView()),
      ModalRoute.withName("/"),
    );
  }

  choiseStyle() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(9),
      gradient: LinearGradient(
        colors: [
          Color(0xFFE8E8E8),
          Color(0xFFF5F5F5),
        ],
      ),
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

  //popup
  Future<void> _showMyDialog(msg) async {
    final comment = TextEditingController();

    var pic = "1";
    if (msg == "ยอดเยี่ยม") {
      pic = "1";
    } else if (msg == "ดี") {
      pic = "2";
    } else if (msg == "พอสมควร") {
      pic = "3";
    } else if (msg == "แย่") {
      pic = "4";
    } else if (msg == "แย่มาก") {
      pic = "5";
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            0,
          ),
          //title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //img
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 16),
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/pop_vote$pic.png',
                        height: 96,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.cancel_sharp,
                          color: Color(0xFF1084F8),
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
                //title
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ท่านต้องการโหวต',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '"$msg"',
                        style: TextStyle(
                          color: Color(0xFF65A5D8),
                        ),
                      ),
                      Text(
                        'ให้กับ',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                //title2
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'เทศบาลนครนนทบุรี',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF78B10E),
                    ),
                  ),
                ),
                //comment
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  margin: EdgeInsets.only(top: 16),
                  height: 5 * 24.0,
                  child: TextField(
                    controller: comment,
                    maxLines: 5,
                    decoration: InputDecoration(
                      isDense: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      hintText: 'ข้อเสนอแนะเพิ่มเติม',
                    ),
                  ),
                ),
                //text
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  margin: EdgeInsets.only(top: 16),
                  child: Text(
                    "ทุกความคิดเห็นของคุณจะเป็นประโยชน์ให้เรา นำไปพัฒนาเทศบาลนครนนทบุรีให้ดียิ่งขึ้น",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF929292),
                    ),
                  ),
                ),
                //btnsent
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  margin: EdgeInsets.only(top: 16, bottom: 24),
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFFE6DF16)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ),
                    onPressed: () {
                      insertData(msg, comment.text);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "โหวต",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: "ประเมินความพึงพอใจ",
        isHaveArrow: "1",
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFFFFFFF),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: (isVoted == "1")
                ? Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.center,
                    child: Text("ท่านได้ให้คะแนนความพึงพอใจแล้ว"),
                  )
                : Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 32),
                        child: Text("กรุณาให้คะแนนความพึงพอใจการให้บริการ"),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog("ยอดเยี่ยม");
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(top: 32),
                          decoration: choiseStyle(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/list_vote1.png',
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    "ยอดเยี่ยม",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog("ดี");
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(top: 32),
                          decoration: choiseStyle(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/list_vote2.png',
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    "ดี",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog("พอสมควร");
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(top: 32),
                          decoration: choiseStyle(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/list_vote3.png',
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    "พอสมควร",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog("แย่");
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(top: 32),
                          decoration: choiseStyle(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/list_vote4.png',
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    "แย่",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showMyDialog("แย่มาก");
                        },
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(top: 32),
                          decoration: choiseStyle(),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/list_vote5.png',
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Text(
                                    "แย่มาก",
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 32),
                        child: Text(
                          "ทุกความคิดเห็นของคุณจะเป็นประโยชน์ให้เรา\nนำไปพัฒนาเทศบาลนครนนทบุรีให้ดียิ่งขึ้น",
                          textAlign: TextAlign.center,
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
