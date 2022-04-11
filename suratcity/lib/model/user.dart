//import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  static FirebaseMessaging _firebaseMessaging;
  static SharedPreferences _sharedPrefs;
  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
    _firebaseMessaging = FirebaseMessaging();
  }
/*
  bool isLogin = false;
  String uid;
  String fullname;
  String username;
  String password;*/

  bool get isLogin => _sharedPrefs.getBool('isLogin') ?? false;
  set isLogin(bool value) {
    _sharedPrefs.setBool('isLogin', value);
  }

  String get uid => _sharedPrefs.getString('uid') ?? "";
  set uid(String value) {
    _firebaseMessaging.subscribeToTopic("uid_" + value);
    _sharedPrefs.setString('uid', value);
  }

  String get username => _sharedPrefs.getString('username') ?? "";
  set username(String value) {
    _sharedPrefs.setString('username', value);
  }

  String get password => _sharedPrefs.getString('password') ?? "";
  set password(String value) {
    _sharedPrefs.setString('password', value);
  }

  String get email => _sharedPrefs.getString('email') ?? "";
  set email(String value) {
    _sharedPrefs.setString('email', value);
  }

  String get priv => _sharedPrefs.getString('priv') ?? "";
  set priv(String value) {
    _sharedPrefs.setString('priv', value);
  }

  String get citizen_id => _sharedPrefs.getString('citizen_id') ?? "";
  set citizen_id(String value) {
    _sharedPrefs.setString('citizen_id', value);
  }

  String get fullname => _sharedPrefs.getString('fullname') ?? "";
  set fullname(String value) {
    _sharedPrefs.setString('fullname', value);
  }

  String get authen_token => _sharedPrefs.getString('authen_token') ?? "";
  set authen_token(String value) {
    _sharedPrefs.setString('authen_token', value);
  }

  String get phone => _sharedPrefs.getString('phone') ?? "";
  set phone(String value) {
    _sharedPrefs.setString('phone', value);
  }

  String get facebook_id => _sharedPrefs.getString('facebook_id') ?? "";
  set facebook_id(String value) {
    _sharedPrefs.setString('facebook_id', value);
  }

  String get line_id => _sharedPrefs.getString('line_id') ?? "";
  set line_id(String value) {
    _sharedPrefs.setString('line_id', value);
  }

  String get google_id => _sharedPrefs.getString('google_id') ?? "";
  set google_id(String value) {
    _sharedPrefs.setString('google_id', value);
  }

  String get apple_id => _sharedPrefs.getString('apple_id') ?? "";
  set apple_id(String value) {
    _sharedPrefs.setString('apple_id', value);
  }

  String get userclass => _sharedPrefs.getString('userclass') ?? "";
  set userclass(String value) {
    if (value == "superadmin") {
      _firebaseMessaging.subscribeToTopic("admin");
    } else {
      _firebaseMessaging.subscribeToTopic(value);
    }
    _sharedPrefs.setString('userclass', value);
  }

  String get avatar => _sharedPrefs.getString('avatar') ?? "";
  set avatar(String value) {
    _sharedPrefs.setString('avatar', value);
  }

  String get isNoti => _sharedPrefs.getString('isNoti') ?? "";
  set isNoti(String value) {
    _sharedPrefs.setString('isNoti', value);
  }

  String get countNoti => _sharedPrefs.getString('countNoti') ?? "";
  set countNoti(String value) {
    _sharedPrefs.setString('countNoti', value);
  }

  logout() async {
    _firebaseMessaging.unsubscribeFromTopic("uid_" + uid);
    if (userclass == "superadmin") {
      _firebaseMessaging.unsubscribeFromTopic("admin");
    } else {
      _firebaseMessaging.unsubscribeFromTopic(userclass);
    }

    _firebaseMessaging.deleteInstanceID().then((value) {
      print('deleted all' + value.toString());
    });

    if (Platform.isIOS) {
      //_firebaseMessaging.subscribeToTopic("th.go.suratcity.app");
      _firebaseMessaging.subscribeToTopic("th.go.suratcity");
    } else {
      _firebaseMessaging.subscribeToTopic("th.go.suratcity");
    }

    _firebaseMessaging.subscribeToTopic("news");

    await _sharedPrefs.clear();
  }
}
