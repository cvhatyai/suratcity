import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cvapp/system/Info.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../AppBarView.dart';

var data;

class FaqWebView extends StatefulWidget {
  FaqWebView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _FaqWebViewState createState() => _FaqWebViewState();
}

class _FaqWebViewState extends State<FaqWebView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarView(
          title: "FAQ ถาม-ตอบ",
          isHaveArrow: widget.isHaveArrow,
        ),
        body: Container(
          color: Color(0xFFFFFFFF),
          padding: EdgeInsets.only(left: 8, right: 8),
          child: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: Info().baseUrl + 'faq?app=1',
          ),
        ),
      ),
    );
  }
}
