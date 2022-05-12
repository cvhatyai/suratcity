import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:url_launcher/url_launcher.dart';

List<Map<String, dynamic>> chatArr;
var data;
var data2;

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    // TODO: implement initState

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm').format(now);

    chatArr = [];

    var defaultSubject1 = {
      'chatText':
          'สวัสดีครับ... วันนี้มีอะไรให้ช่วยครับ ถามมาได้เลย จะรีบไปหาคำตอบให้ครับ',
      'chatTime': formattedDate,
      'type': "bot",
    };

    chatArr.add(defaultSubject1);

    super.initState();
  }

  final questionText = TextEditingController();
  ScrollController _scrollController = ScrollController();

  letAskQuestion(questionTextVal, {isID = false, subjectID = ""}) {
    //updateView
    print("questionTextVal" + questionTextVal);
    print("questionTextVal2" + isID.toString());

    if (questionTextVal.toString() != "") {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('HH:mm').format(now);

      var userSubject = {
        'chatText': questionTextVal.toString(),
        'chatTime': formattedDate,
        'type': "user",
      };
      chatArr.add(userSubject);

      sendQuestion(questionTextVal.toString().trim(), isID, subjectID);
    }

    print("chatArr" + chatArr.length.toString());
    print(chatArr.toString());

    questionText.clear();
    setState(() {
      isHaveHint = false;
    });
  }

  sendQuestion(keyword, isID, subjectID) async {
    Map _map = {};
    if (isID) {
      _map.addAll({
        "id": subjectID,
      });
    } else {
      _map.addAll({
        "keyword": keyword,
      });
    }

    //EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postNewsList(http.Client(), body, _map);
  }

  Future<List<AllList>> postNewsList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().serviceDescription),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
    print("responseBody" + responseBody.toString());
    data = [];

    var tmpJson = json.decode(responseBody);

    print(tmpJson["result"].length.toString());

    if (tmpJson["result"].length == 1) {
      var botSubjectData = tmpJson["result"][0]["message"].toString();
      var botLinkData = tmpJson["result"][0]["link"].toString();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('HH:mm').format(now);

      var botSubject = {
        'chatText': botSubjectData,
        'chatLink': botLinkData,
        'chatTime': formattedDate,
        'type': "bot",
      };

      chatArr.add(botSubject);
    } else if (tmpJson["result"].length > 1) {
      var botSubjectData = tmpJson["subject"].toString();
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('HH:mm').format(now);

      var tmpSubject = "";
      for (int i = 0; i < tmpJson["result"].length; i++) {
        tmpSubject += "\n\n- " + tmpJson["result"][i]["message"].toString();
      }

      var botSubject = {
        'chatText': botSubjectData + tmpSubject,
        'chatTime': formattedDate,
        'type': "bot",
      };

      chatArr.add(botSubject);
    }

    setState(() {});

    Timer(
        Duration(milliseconds: 100),
        () => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 100,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ));

    //EasyLoading.dismiss();
  }

  var isHaveHint = false;

  getHintSubject(text) async {
    if (text != "") {
      Map _map = {};
      _map.addAll({
        "keyword": text,
      });

      print("_map : " + _map.toString());
      var body = json.encode(_map);
      postSubjectList(http.Client(), body, _map);
    } else {
      setState(() {
        isHaveHint = false;
      });
    }
  }

  Future<List<AllList>> postSubjectList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().serviceSubject),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseServiceSubjectList(response.body);
  }

  List<AllList> parseServiceSubjectList(String responseBody) {
    data2 = [];
    data2 = json.decode(responseBody);

    print("aaa" + data2['result'].toString());
    print("aaa" + data2['result'].length.toString());
    //print("aaa" + data2['result'][0].toString());

    if (data2['result'].length != 0) {
      setState(() {
        isHaveHint = true;
      });
    } else {
      setState(() {
        isHaveHint = false;
      });
    }
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
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('HH:mm').format(now);

    double heightDefaultHintView =
        (MediaQuery.of(context).size.height * 0.35).toDouble();

    if (isHaveHint == true) {
      if (data2 != null && data2.length != 0) {
        heightDefaultHintView = (50 * data2['result'].length).toDouble();
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Color(0xFFFFFFFF),
          padding: EdgeInsets.only(top: 16),
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 200),
                controller: _scrollController,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/images/faq1.png',
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0; i < chatArr.length; i++)
                    (chatArr[i]["type"] == "bot")
                        ? Container(
                            margin: EdgeInsets.only(left: 8, right: 8, top: 16),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'assets/images/faq2.png',
                                      width: 64,
                                    ),
                                    alignment: Alignment.topCenter,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (chatArr[i]["chatLink"] != "") {
                                          _launchInBrowser(
                                              chatArr[i]["chatLink"]);
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                          ),
                                          border: Border.all(
                                            color: Color(0xFF7C1B6A),
                                            width: 1.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          chatArr[i]["chatText"],
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        /*child: Html(
                                          data: chatArr[i]["chatText"],
                                          onLinkTap: (url) {
                                            _launchInBrowser(url);
                                          },
                                        ),*/
                                        /*child:  MarkdownBody(
                                           data: chatArr[i]["chatText"],
                                           onTapLink: (text, url, title) {
                                             launch(url);
                                           },
                                         ),*/
                                      ),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      chatArr[i]["chatTime"],
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(left: 8, right: 8, top: 16),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      chatArr[i]["chatTime"],
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF7C1B6A),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        chatArr[i]["chatText"],
                                        style: TextStyle(fontSize: 12,color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/faq3.png',
                      ),
                      Positioned(
                        bottom: 20,
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                    border: Border.all(
                                      color: Color(0xFFe6df16),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: questionText,
                                          onChanged: (text) {
                                            getHintSubject(text);
                                          },
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8),
                                            hintText:
                                                "พิมพ์คำถามของคุณที่นี่..",
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          letAskQuestion(questionText.text);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFe6df16),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(0xFFe6df16),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.search,
                                              color: Color(0xFF7C1B6A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (data2 != null && data2.length != 0)
                  ? Visibility(
                      visible: isHaveHint,
                      child: Positioned(
                        bottom: 80,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35,
                          ),
                          child: Container(
                            height: heightDefaultHintView,
                            margin: EdgeInsets.all(4),
                            padding: EdgeInsets.all(8),
                            width: MediaQuery.of(context).size.width * 0.93,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                              border: Border.all(color: Colors.black12),
                              color: Colors.white,
                            ),
                            child: ListView(
                              children: [
                                for (int i = 0; i < data2['result'].length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      print(
                                          data2['result'][i]["id"].toString());
                                      letAskQuestion(
                                          data2['result'][i]["message"],
                                          isID: true,
                                          subjectID: data2['result'][i]["id"]
                                              .toString());
                                      if (FocusScope.of(context).isFirstFocus) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          height: 30,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            data2['result'][i]["message"],
                                            overflow: TextOverflow.ellipsis,
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
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
