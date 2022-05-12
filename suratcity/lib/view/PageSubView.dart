
import 'package:cvapp/system/widht_device.dart';
import 'package:flutter/material.dart';

class PageSubView extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String isHaveArrow;
  final Widget widget;

  PageSubView({
    Key key,
    this.title = "",
    this.isHaveArrow = "",
    this.widget,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  _PageSubViewState createState() => _PageSubViewState();
}

class _PageSubViewState extends State<PageSubView> {
  leading() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xFFE5C21C),
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  double height = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade800,
            Colors.white,
          ],
          stops: [
            0,
            0.5,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            width: WidhtDevice().widht(context),
            height: MediaQuery.of(context).size.height,
            // decoration: BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("assets/bg/sub.png"),
            //     alignment: Alignment.topCenter,
            //     fit: BoxFit.contain,
            //   ),
            // ),
            child: Scaffold(
              backgroundColor: Colors.white.withOpacity(0),
              appBar: AppBar(
                leading: (widget.isHaveArrow == "") ? Container() : leading(),
                backgroundColor: Colors.white.withOpacity(0),
                title: Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      ),
                ),
                elevation: 0,
                centerTitle: true,
              ),
              body: Container(
                height: MediaQuery.of(context).size.height - height,
                child: widget.widget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
