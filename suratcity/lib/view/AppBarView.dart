import 'package:flutter/material.dart';
import 'package:cvapp/view/phone/PhoneDetailView.dart';
import 'package:cvapp/view/phone/PhoneEditView.dart';

class AppBarView extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String isHaveArrow;

  AppBarView({
    Key key,
    this.title = "",
    this.isHaveArrow = "",
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  _AppBarViewState createState() => _AppBarViewState();
}

class _AppBarViewState extends State<AppBarView> {
  leading() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: Color(0xFFe5c21c),
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: (widget.isHaveArrow == "") ? Container() : leading(),
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
      ),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Image(
        image: AssetImage(
          'assets/images/app_bar.png',
        ),
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
      backgroundColor: Color(0xFFFFFFFF),
    );
  }
}
