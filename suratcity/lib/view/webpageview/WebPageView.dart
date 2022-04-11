import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AppBarView.dart';

var data;

class WebPageView extends StatefulWidget {
  WebPageView(
      {Key key,
      this.isHaveArrow = "",
      this.title = "",
      this.cmd = "",
      this.edit = ""})
      : super(key: key);
  final String isHaveArrow;
  final String title;
  final String cmd;
  final String edit;

  @override
  _WebPageViewState createState() => _WebPageViewState();
}

class _WebPageViewState extends State<WebPageView> {
  bool isUploadFile = false;
  Widget _webView = Container();
  var user = User();

  final _citizenID = TextEditingController();
  bool _validateCitizenID = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    //getUserDetail();
    checkCmd();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onStateChanged.listen((viewState) {
      print("your data : " + viewState.type.toString());
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

  checkCmd() {
    var thisCmdNeedCitizen = ["tax", "garbage", "elder", "disabled"];
    if (thisCmdNeedCitizen.contains(widget.cmd)) {
      if (user.userclass == "member") {
        getUsers();
      } else {
        gotoPage();
      }
    } else {
      gotoPage();
    }
  }

  getUsers() async {
    await user.init();
    print("citizen_id :" + user.citizen_id);
    if (user.citizen_id == "") {
      //ไปกรอก รหัส ปชช
      _showCitizenDialog(context);
    } else {
      //ไป หน้าเว็บนั้นเลย
      gotoPage();
    }
  }

  gotoPage() {
    EasyLoading.show(status: 'loading...');
    var url = "";
    if (widget.cmd == "tax") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "tax_request/showListWeb?app=1";
    } else if (widget.cmd == "taxHistory") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "tax_request/showListWeb?app=1";

      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "garbage") {
      if (user.userclass == "member") {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "garbage/showListWeb?app=1";

        setState(() {
          isUploadFile = true;
        });
      } else {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/edit/" +
            widget.edit +
            "?app=1";

        setState(() {
          isUploadFile = true;
        });
      }
    } else if (widget.cmd == "elder") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "form_elder?app=1";

      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "disabled") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "form_disabled?app=1";

      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "map_complain") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "inform2/showMap?app=1";
    } else if (widget.cmd == "graph_complain") {
      url = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "inform2/graphList/graph1?app=1";
    } else if (widget.cmd == "tax_admin") {
      if (widget.edit != "") {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/tax_request/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/tax_request/showList?app=1";
      }
      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "garbage_admin") {
      if (widget.edit != "") {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/edit" +
            widget.edit +
            "?app=1";
      } else {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/showList?app=1";
      }

      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "disabled_admin") {
      if (widget.edit != "") {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_disabled/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_disabled/showList?app=1";
      }
      setState(() {
        isUploadFile = true;
      });
    } else if (widget.cmd == "elder_admin") {
      if (widget.edit != "") {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_elder/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_elder/showList?app=1";
      }
      setState(() {
        isUploadFile = true;
      });
    }
    print("url : " + url);

    setState(() {
      print("isUploadFile : " + isUploadFile.toString());
      if (isUploadFile) {
        _webView = WebviewScaffold(
          withLocalStorage: true,
          withJavascript: true,
          withZoom: true,
          allowFileURLs: true,
          withOverviewMode: false,
          url: url,
        );
        EasyLoading.dismiss();
      } else {
        _webView = WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: url,
          onPageFinished: (finish) {
            EasyLoading.dismiss();
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.endsWith(".pdf")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".doc")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".docx")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".xls")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".xlsx")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".jpeg")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".jpg")) {
              _launchInBrowser(request.url);
            } else if (request.url.endsWith(".png")) {
              _launchInBrowser(request.url);
            } else {
              print("bbb");
            }
            return NavigationDecision.navigate;
          },
        );
      }
    });
  }

  checkCitizenID(BuildContext context) async {
    Map _map = {};
    _map.addAll({"pid": _citizenID.text});
    var body = json.encode(_map);
    return postCitizenID(http.Client(), body, _map, context);
  }

  Future<List<AllList>> postCitizenID(
      http.Client client, jsonMap, Map map, BuildContext context) async {
    final response = await client.post(Uri.parse(Info().checkCitizenID),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    print("status : " + status);
    if (status == "success") {
      //Navigator.of(context).pop();
      //อัพเดท เลขบัตร
      updateCitizenID(context);
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  updateCitizenID(BuildContext context) async {
    Map _map = {};
    _map.addAll({
      "citizen_id": _citizenID.text,
      "uid": user.uid,
    });
    print("updateCitizenID : " + _map.toString());
    var body = json.encode(_map);
    postUpdateCitizenID(http.Client(), body, _map, context);
  }

  Future<List<AllList>> postUpdateCitizenID(
      http.Client client, jsonMap, Map map, BuildContext context) async {
    final response = await client.post(Uri.parse(Info().updateCitizenID),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    var rs = json.decode(response.body);
    var status = rs["status"].toString();
    var msg = rs["msg"].toString();
    print("status : " + status);
    if (status == "success") {
      //ไปเว็บวิว
      Navigator.of(context).pop();
      user.citizen_id = _citizenID.text;
      gotoPage();
    } else {
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<void> _showCitizenDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text(
                  'ระบุเลขบัตรประชาชน 13 หลัก',
                  style: TextStyle(fontSize: 16),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Container(
                        height: 50,
                        child: TextField(
                          controller: _citizenID,
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          decoration: InputDecoration(
                            counterText: '',
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1),
                            ),
                            hintText: 'กรอกเลขบัตรประชาชน 13 หลัก',
                            hintStyle: TextStyle(fontSize: 12),
                            errorText: _validateCitizenID
                                ? 'กรุณากรอกเลขบัตรประชาชน 13 หลัก'
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('ยกเลิก'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(this.context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('ดำเนินการต่อ'),
                    onPressed: () {
                      setState(() {
                        _citizenID.text.isEmpty
                            ? _validateCitizenID = true
                            : _validateCitizenID = false;
                        if (!_validateCitizenID) {
                          //Navigator.of(context).pop();
                          //EasyLoading.show(status: 'loading...');
                          if (FocusScope.of(context).isFirstFocus) {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          }
                          checkCitizenID(context);
                        }
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBarView(
        title: widget.title,
        isHaveArrow: widget.isHaveArrow,
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        padding: EdgeInsets.only(left: 8, right: 8),
        child: _webView,
      ),
    ));
  }
}
