import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  final GlobalKey webViewKey = GlobalKey();
  bool allowGoBackWithBackButton;
  String uri;
  String url_service;
  var user = User();
  bool isLogin = false;

  Widget _webView = Container();

  final _citizenID = TextEditingController();
  bool _validateCitizenID = false;

  //newtab
  List<String> newTab = [
    ".pdf",
    ".rar",
    ".doc",
    ".docx",
    ".xls",
    ".xlsx",
    ".jpeg",
    ".jpg",
    ".png",
    ".gif",
    ".xls",
    ".zip"
  ];

  InAppWebViewController webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));
  String url = "";
  PullToRefreshController pullToRefreshController;

  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // getUsers();
    checkCmd();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  checkCmd() {
    var thisCmdNeedCitizen = [
      "tax",
      "pet",
      "complain_medical",
      "garbage",
      "elder",
      "disabled",
      "hiv",
      "sewer_pipe",
      "electricity",
      "civil_registration"
    ];
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

  gotoPage() {
    // EasyLoading.show(status: 'loading...');
    if (widget.cmd == "tax") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "tax_request/formSelect/?app=1";
    } else if (widget.cmd == "pet") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "pet/showList/";
    } else if (widget.cmd == "complain_medical") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "complain_medical/showList/?app=1";
    } else if (widget.cmd == "taxHistory") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "tax_request/showListWeb?app=1";
    } else if (widget.cmd == "garbage") {
      if (user.userclass == "member") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "garbage/showlist/?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/edit/" +
            widget.edit +
            "?app=1";
      }
    } else if (widget.cmd == "elder") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "form_elder/?app=1";
    } else if (widget.cmd == "disabled") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "form_disabled/?app=1";
    } else if (widget.cmd == "hiv") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "form_hiv/?app=1";
    } else if (widget.cmd == "civil_registration") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "civil_registration/?app=1";
    } else if (widget.cmd == "electricity") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "electricity/?app=1";
    } else if (widget.cmd == "sewer_pipe") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "sewer_pipe/?app=1";
    } else if (widget.cmd == "map_complain") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "inform2/showMap/?app=1";
    } else if (widget.cmd == "graph_complain") {
      url_service = Info().baseUrl +
          'app_api_v1/authentication?authen_token=' +
          user.authen_token +
          "&redirect=" +
          Info().baseUrl +
          "inform2/graphList/graph1?app=1";
    } else if (widget.cmd == "tax_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/tax_request/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/tax_request/showList?app=1";
      }
    } else if (widget.cmd == "pet_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/pet/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/pet/showList?app=1";
      }
    } else if (widget.cmd == "complain_medical_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/complain_medical/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/complain_medical/showList?app=1";
      }
    } else if (widget.cmd == "sewer_pipe_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/sewer_pipe/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/sewer_pipe/showList?app=1";
      }
    } else if (widget.cmd == "electricity_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/electricity/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/electricity/showList?app=1";
      }
    } else if (widget.cmd == "civil_registration_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/civil_registration/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/civil_registration/showList?app=1";
      }
    } else if (widget.cmd == "garbage_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/edit" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/garbage/showList?app=1";
      }
    } else if (widget.cmd == "disabled_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_disabled/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_disabled/showList?app=1";
      }
    } else if (widget.cmd == "hiv_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_hiv/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_hiv/showList?app=1";
      }
    } else if (widget.cmd == "general") {
      url_service = Info().baseUrl + 'app_api_v1/history_ios_preview';
    } else if (widget.cmd == "personal") {
      // url_service = Info().baseUrl + 'content/personal_management?app=1';
      url_service =
          'https://www.suratcity.go.th/web/index.php/th/menu-about-us-th/menu-executive-commitee-new-2-th';
    } else if (widget.cmd == "elder_admin") {
      if (widget.edit != "") {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_elder/edit/" +
            widget.edit +
            "?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/form_elder/showList?app=1";
      }
    }

    //ติดตามร้องเรียน
    if (widget.cmd == "followcomplain") {
      if (user.userclass == 'member') {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "inform/showlist?app=1";
      } else {
        url_service = Info().baseUrl +
            'app_api_v1/authentication?authen_token=' +
            user.authen_token +
            "&redirect=" +
            Info().baseUrl +
            "behind/inform/showlist?app=1";
      }
    }

    print("url : " + url);

    setState(() {
      _webView = InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: Uri.parse(url_service)),
        initialOptions: options,
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        androidOnPermissionRequest: (controller, origin, resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          uri = "${navigationAction.request.url}";

          print("urilll : " + uri.toString());

          if (newTab.any(uri.toString().endsWith)) {
            _launchInBrowser(uri.toString());
            return NavigationActionPolicy.CANCEL;
          }

          /*
                        if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                            if (await canLaunch(url)) {
                              // Launch the App
                              await launch(
                                url,
                              );
                              // and cancel the request
                              return NavigationActionPolicy.CANCEL;
                            }
                          }
                        */

          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, url) async {
          pullToRefreshController.endRefreshing();
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        onLoadError: (controller, url, code, message) {
          pullToRefreshController.endRefreshing();
        },
        onProgressChanged: (controller, progress) {
          if (progress == 100) {
            pullToRefreshController.endRefreshing();
          }
          setState(() {
            this.progress = progress / 100;
            urlController.text = this.url;
          });
        },
        onUpdateVisitedHistory: (controller, url, androidIsReload) {
          setState(() {
            this.url = url.toString();
            urlController.text = this.url;
          });
        },
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage);
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                    child: Text(
                      'ยกเลิก',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(this.context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'ดำเนินการต่อ',
                      style: TextStyle(color: Colors.black),
                    ),
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

  backPageView() {
    String urigoback = url.split("/").last;
    var uriBehindBack = url.split("/");
    print('uriBehindBack ${uriBehindBack[uriBehindBack.length - 2]}');
    print('uribackpageview ${urigoback.toString()}');
    String edit = uriBehindBack[uriBehindBack.length - 2].toString();
    if (edit == "edit") {
      Navigator.of(context).pop();
    } else if (urigoback == 'formselect?app=1' ||
        urigoback == 'showlist?app=1' ||
        urigoback == '' ||
        urigoback == 'showList?app=1' ||
        urigoback == 'graph1?app=1' ||
        urigoback == '?app=1' ||
        urigoback == 'personal_management?app=1' ||
        urigoback == 'graph1?secret_key=' ||
        urigoback == 'menu-executive-commitee-new-2-th' ||
        urigoback == 'history_ios_preview') {
      Navigator.of(context).pop();
    } else {
      webViewController.evaluateJavascript(
          source: "setTimeout(function() {backPageView()}, 300);");
    }
  }

  leading() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xFFFFFFFF),
      ),
      onPressed: () => backPageView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: (widget.isHaveArrow == "") ? Container() : leading(),
          title: Text(
            widget.title,
            style: TextStyle(fontSize: 23, color: Color(0xFFFFFFFF)),
          ),
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Image(
            image: AssetImage(
              'assets/images/app_bar.png',
            ),
            fit: BoxFit.cover,
          ),
          backgroundColor: Color(0xFFFFFFFF),
        ),
        body: Container(
          color: Color(0xFFFFFFFF),
          margin: EdgeInsets.only(top: 20),
          padding: EdgeInsets.only(left: 8, right: 8),
          child: _webView,
        ),
      ),
    );
  }
}
