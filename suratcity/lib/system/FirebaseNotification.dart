import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cvapp/view/FrontPageView.dart';

import '../main.dart';

String channelId = "1000";
String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

class FirebaseNotification {
  FirebaseMessaging _firebaseMessaging;

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

  init() {
    _firebaseMessaging = FirebaseMessaging();

    if (Platform.isIOS) {
      _firebaseMessaging.subscribeToTopic("th.go.suratcity");
    } else {
      _firebaseMessaging.subscribeToTopic("th.go.suratcity");
    }

    _firebaseMessaging.subscribeToTopic("news");

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: false));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("wittawat onMessage: $message");
        String title = "";
        String body = "";
        if (message != null) {
          if (message["data"] != null) {
            /*Map mapNotification = message["notification"];
          title = mapNotification["title"];
          body = mapNotification["body"];*/
            Map data = message["data"];
            title = data["subject"];
            body = data["descripiton"];
          } else {
            body = message["subject"];
          }
          //sendNotification(title: title, body: body, data: "");
          if (Platform.isAndroid) {
            sendNotification(title: title, body: body, data: message["data"]);
          } else {
            sendNotification(title: title, body: body, data: message);
          }
        }
        //_showItemDialog(message);
      },
      onBackgroundMessage:
          Platform.isAndroid ? myBackgroundMessageHandler : null,
      onLaunch: (Map<String, dynamic> message) async {
        //onLaunch คือ ถ้ามาจาก firebase แบบปิดแอพอยู่แล้วกด แบนเนอร์ โนติ
        print("wittawat onLaunch: $message");
        String title = "";
        String body = "";
        if (message != null) {
          if (message["data"] != null) {
            /*Map mapNotification = message["notification"];
          title = mapNotification["title"];
          body = mapNotification["body"];*/
            Map data = message["data"];
            title = data["subject"];
            body = data["descripiton"];
          } else {
            body = message["subject"];
          }

          /////////////////////////ต้องทำแบบนี้
          var payload;
          if (Platform.isAndroid) {
            payload = json.encode(message["data"]);
          } else {
            //ของ ios ยังไม่ชัวร์แบบ ปิดแอพ เพราะตอนนี้ krc ปิดแอพแล้วไม่เข้า แต่แบบ เปิดแอพอยู่ได้แล้ว ด้านบน onMessage
            payload = json.encode(message);
          }
          selectedNotificationPayload = payload;
          //sendNotification(title: title, body: body, data: message["data"]);
        }
        //await Utils().sendDebug("aaaaaa");
        //_navigateToItemDetail(message);

        /*Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => FrontPageView(
              payload: selectedNotificationPayload,
            ),
          ),
        );*/

        //เก็บ pref ไว้ก่อน ไม่ได้แบบนี้
        //setPref(message["data"]);
      },
      onResume: (Map<String, dynamic> message) async {
        print("wittawat onResume: $message");
        String title = "";
        String body = "";
        if (message != null) {
          if (message["data"] != null) {
            Map data = message["data"];
            title = data["subject"];
            body = data["description"];
          } else {
            body = message["subject"];
          }

          var payload;
          if (Platform.isAndroid) {
            payload = json.encode(message["data"]);
          } else {
            payload = json.encode(message);
          }
          selectedNotificationPayload = payload;
          await navigatorKey.currentState.pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  FrontPageView(payload: selectedNotificationPayload),
            ),
          );
        }
      },
    );
  }

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print("wittawat fms data");
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print("wittawat fms notification");
    }
    // Or do other work.
  }

  sendNotification({String title, String body, Map data}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName, channelDescription,
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    final payload = json.encode(data);
    await flutterLocalNotificationsPlugin.show(
        111, title, body, platformChannelSpecifics,
        payload: payload.toString());
  }
}
