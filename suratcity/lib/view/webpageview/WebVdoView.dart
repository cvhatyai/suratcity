import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebVdoView extends StatefulWidget {
  WebVdoView({Key key, this.vdo = ""}) : super(key: key);
  final String vdo;
  @override
  _WebVdoViewState createState() => _WebVdoViewState();
}

class _WebVdoViewState extends State<WebVdoView> {
  bool isUploadFile = false;
  Widget _webView = Container();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    gotoVdo();
    final flutterWebviewPlugin = FlutterWebviewPlugin();
    flutterWebviewPlugin.onStateChanged.listen((viewState) {
      print("your data : " + viewState.type.toString());
    });
  }

  gotoVdo() {
    var url = "";
    // url = "https://geo.dailymotion.com/player/x8nxb.html?video=x8anisk";
    url = widget.vdo;
    setState(() {
      isUploadFile = true;
    });
    setState(() {
      if (isUploadFile) {
        _webView = WebviewScaffold(
          withLocalStorage: true,
          withJavascript: true,
          withZoom: true,
          allowFileURLs: true,
          withOverviewMode: false,
          url: url,
          /*initialChild: Container(
            // color: Colors.redAccent,
            child: const Center(
              child: Icon(
                Icons.play_circle_filled_outlined,
              ),
            ),
          ),*/
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Vdo"),
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(child: _webView),
                  Icon(
                    Icons.play_circle_filled_outlined,
                    color: Colors.red,
                    size: 500,
                  ),
                ],
              ),
            ),
            // Expanded(child: Container()),
          ],
        ),
      ),
    ));
  }
}
