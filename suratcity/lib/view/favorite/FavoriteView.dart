import 'dart:convert';

import 'package:flutter/material.dart';

import '../AppBarView.dart';
import 'CallFavListView.dart';
import 'TravelFavListView.dart';

class FavoriteView extends StatefulWidget {
  FavoriteView({Key key, this.isHaveArrow = ""}) : super(key: key);
  final String isHaveArrow;

  @override
  _FavoriteViewState createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {

  int currentTab = 0;
  final List<Widget> myPage = <Widget>[
    TravelFavListView(),
    CallFavListView(),
  ];



  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBarView(
            title: "รายการโปรด",
            isHaveArrow: widget.isHaveArrow,
          ),
          body: Column(
            children: [
              Container(
                height: 50,
                child: TabBar(
                  onTap: (index) {
                    print(index.toString());
                    setState(() {
                      currentTab = index;
                    });
                  },
                  tabs: [
                    Container(
                      child: Text(
                        "กิจกรรม/สถานที่",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (currentTab == 0) ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "หมายเลขโทรศัพท์",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (currentTab == 1) ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: myPage.map((Widget widget) {
                    return widget;
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
