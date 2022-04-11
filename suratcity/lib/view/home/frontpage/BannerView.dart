import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/system/Info.dart';
import 'package:url_launcher/url_launcher.dart';

var data;
List<String> imgList = [];

class BannerView extends StatefulWidget {
  @override
  _BannerViewState createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  int _currentPage = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBannerList();
  }

  getBannerList() async {
    Map _map = {};
    _map.addAll({
      "rows": "6",
    });

    EasyLoading.show(status: 'loading...');
    print("_map : " + _map.toString());
    var body = json.encode(_map);
    return postBannerList(http.Client(), body, _map);
  }

  Future<List<AllList>> postBannerList(
      http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().bannerList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
    imgList.clear();

    data = [];
    data.addAll(json.decode(responseBody));

    if (data != null && data.length != 0) {
      for (var i = 0; i < data.length; i++) {
        imgList.add(data[i]['display_image'].toString());
      }
    }

    print("imgList :" + imgList.length.toString());

    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
    EasyLoading.dismiss();
  }

  Widget theIndicator(_currentPage, index) {
    if (_currentPage == index) {
      return Container(
        width: 24.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(9.0),
          ),
          color: Color(0xFF388DFC),
        ),
      );
    } else {
      return Container(
        width: 8.0,
        height: 8.0,
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFB4B4B4),
        ),
      );
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
    return Column(
      children: [
        (imgList.length >= 1)
            ? Container(
                margin: EdgeInsets.only(top: 16),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(9.0),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 3.0,
                  ),
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      autoPlayAnimationDuration: Duration(milliseconds: 100),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentPage = index;
                        });
                      }),
                  items: imgList.map((image) {
                    return Builder(
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () {
                            if (data[_currentPage]["url"] != "") {
                              _launchInBrowser(data[_currentPage]["url"]);
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.97,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(9.0),
                              ),
                            ),
                            child: Image.network(
                              image.trim(),
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(1),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              )
            : Container(
                margin: EdgeInsets.only(top: 32),
                height: 140,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(9.0),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 3.0,
                  ),
                ),
                child: Image.network(
                  Info().baseUrl + "images/nopic_banner.png",
                ),
              ),
        if (imgList.length > 1)
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((image) {
                int index = imgList.indexOf(image);
                return theIndicator(_currentPage, index);
              }).toList(),
            ),
          ),
      ],
    );
  }
}
