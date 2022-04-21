import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cvapp/system/FirebaseNotification.dart';
import 'package:cvapp/system/Info.dart';
import 'package:package_info/package_info.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'model/AllList.dart';
import 'view/FrontPageView.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

String selectedNotificationPayload = "";

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "MainNavigator"); //ให้ไปหน้านั้นได้เมื่อกดจาก noti

void main() async {
  //SharedPreferences.setMockInitialValues({});
  //WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails.payload;
    //await Utils().sendDebug(selectedNotificationPayload);
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification: (
            int id,
            String title,
            String body,
            String payload,
          ) async {
            didReceiveLocalNotificationSubject.add(
              ReceivedNotification(
                id: id,
                title: title,
                body: body,
                payload: payload,
              ),
            );
          });
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });

  runApp(
    MaterialApp(
      title: 'ทน.สุราษฎร์ธานี',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      //builder: EasyLoading.init(),
      builder: EasyLoading.init(
        builder: (BuildContext context, Widget child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: child,
          );
        },
      ),
    ),
  );
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _noti = FirebaseNotification();

  @override
  void initState() {
    super.initState();
    //isUpDateApp();
    //isLogin();

    /* Timer(Duration(seconds: 2), () {
      _initPackageInfo();
    });*/

    _noti.init();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    _noti.init();
    _initPackageInfo();
    //isUpDateApp();
  }

  void _configureDidReceiveLocalNotificationSubject() {
    print("_configureDidReceiveLocala");
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      print("iosiosios");
      /*await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();

              },
              child: const Text('Ok'),
            )
          ],
        ),
      );*/
      print("_configureDidReceiveLocalb");
    });
    print("_configureDidReceiveLocalc");
  }

  void _configureSelectNotificationSubject() {
    print("_configureSelectNotia");
    selectNotificationSubject.stream.listen((String payload) async {
      print("_configureSelectNotib : " + payload);
      //await Navigator.pushNamed(context, '/secondPage');
      //\if (isLogin) {
      await navigatorKey.currentState.pushReplacement(
        MaterialPageRoute(
          builder: (context) => FrontPageView(payload: payload),
        ),
      );
      //}
    });
    print("_configureSelectNotic");
  }

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    isUpDateApp();
    return;
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    _ParamCheckAppData();
  }

  _ParamCheckAppData() async {
    Map _map = {};
    String platform;
    if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "android";
    }

    _map.addAll({
      "platform": platform,
      "version": _packageInfo.version,
      //"version": "1.0.0",
    });

    print("_mapVersion" + _map.toString());

    var body = json.encode(_map);
    postCheckAppData(http.Client(), body, _map);
  }

  Future<List<AllList>> postCheckAppData(
    http.Client client,
    jsonMap,
    Map map,
  ) async {
    final response = await client.post(Uri.parse(Info().checkAppVersion),
        headers: {"Content-Type": "application/json"}, body: jsonMap);

    var data = json.decode(response.body);
    if (data["status"].toString() == "0") {
      checkAppVersion(data["msg"].toString(), data["url"].toString(),
          data["important"].toString());
    } else {
      isUpDateApp();
    }
  }

  Future<void> checkAppVersion(msg, url, important) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                if (important == "1") {
                  _launchInBrowser(url);
                  Navigator.of(context).pop();
                } else {
                  isUpDateApp();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
      exit(0);
    } else {
      throw 'Could not launch $url';
    }
  }

  isUpDateApp() {
    Timer(
      Duration(seconds: 2),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => FrontPageView(
            payload: selectedNotificationPayload,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.png"),
            fit: BoxFit.cover,
            alignment: FractionalOffset.topCenter,
          ),
        ),
      ),
    );
  }
}
