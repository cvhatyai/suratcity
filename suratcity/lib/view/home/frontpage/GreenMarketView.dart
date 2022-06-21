import 'dart:convert';

import 'package:cvapp/model/AllList.dart';
import 'package:cvapp/model/user.dart';
import 'package:cvapp/system/Info.dart';
import 'package:cvapp/view/greenmarket/GreenMarketAddView.dart';
import 'package:cvapp/view/greenmarket/GreenMarketDetailView.dart';
import 'package:cvapp/view/greenmarket/GreenMarketListView.dart';
import 'package:cvapp/view/login/LoginView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

var data;

class GreenMarketView extends StatefulWidget {
  //const GreenMarketView({Key? key}) : super(key: key);

  @override
  _GreenMarketViewState createState() => _GreenMarketViewState();
}

class _GreenMarketViewState extends State<GreenMarketView> {
  @override
  var user = User();
  bool isLogin = false;

  void initState() {
    // TODO: implement initState
    super.initState();
    getUsers();
  }

  getUsers() async {
    await user.init();
    setState(() {
      isLogin = user.isLogin;
    });
    getList();
  }

  getList() async {
    Map _map = {};
    _map.addAll({
      "rows": "6",
    });
    var body = json.encode(_map);
    return postList(http.Client(), body, _map);
  }

  Future<List<AllList>> postList(http.Client client, jsonMap, Map map) async {
    final response = await client.post(Uri.parse(Info().marketList),
        headers: {"Content-Type": "application/json"}, body: jsonMap);
    parseNewsList(response.body);
  }

  List<AllList> parseNewsList(String responseBody) {
    data = [];
    data.addAll(json.decode(responseBody));
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    parsed.map<AllList>((json) => AllList.fromJson(json)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new ExactAssetImage('assets/images/main/mk_bg.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 5),
                // height: MediaQuery.of(context).size.height * 0.47,
                height: 340,
                child: Stack(
                  children: [
                    //list
                    (data != null && data.length != 0)
                        ? Container(
                            margin: EdgeInsets.only(top: 98),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for (int i = 0; i < data.length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GreenMarketDetailView(
                                            topicID: data[i]["id"],
                                            title: "ตลาดชาวบ้าน",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      width: MediaQuery.of(context).size.width *
                                          0.45,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.13,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(6),
                                              ),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                              image: DecorationImage(
                                                image: (data[i]
                                                            ["display_image"] !=
                                                        "")
                                                    ? NetworkImage(data[i]
                                                            ["display_image"]
                                                        .trim())
                                                    : AssetImage(
                                                        'assets/images/main/test.png'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 16),
                                            child: Text(
                                              data[i]["productName"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            // height: MediaQuery.of(context)
                                            //         .size
                                            //         .height *
                                            //     0.04,
                                            child: Text(
                                              data[i]["productDetail"],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/main/shop.png',
                                                  width: 10,
                                                  color: Color(0xFF8C1F78),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 6),
                                                    child: Text(
                                                      data[i]["shopName"],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF686868),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/main/pin.png',
                                                  width: 10,
                                                  color: Color(0xFF8C1F78),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 6),
                                                    child: Text(
                                                      data[i]["shopAddress"],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF686868),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (data[i]["hits"] != "")
                                            Container(
                                              margin: EdgeInsets.only(top: 8),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container()),
                                                  Image.asset(
                                                    'assets/images/main/hit.png',
                                                    width: 12,
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 4),
                                                    child: Text(
                                                      data[i]["hits"],
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Color(0xFF1D1D1D),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text("ไม่มีข้อมูล"),
                          ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            // alignment: Alignment.topRight,
            margin: EdgeInsets.only(bottom: 16),
            // padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (!isLogin) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginView(
                              isHaveArrow: "1",
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GreenMarketAddView(
                              isHaveArrow: "1",
                            ),
                          ),
                        );
                      }
                    },
                    child: Image.asset('assets/images/main/mk_btn.png',
                        alignment: Alignment.bottomRight
                        // height: 32,
                        ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GreenMarketListView(
                            isHaveArrow: "1",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Image.asset(
                        'assets/images/main/more.png',
                        height: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
