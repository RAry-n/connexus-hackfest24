import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/utils.dart';
import '../main.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../pages/video.dart';

class NotificationServices {
  static ReceivedAction? intitialAction;

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'video call channel',
          channelDescription: 'channel for video calls',
          importance: NotificationImportance.Max,
          defaultPrivacy: NotificationPrivacy.Public,
          defaultColor: Colors.transparent,
          locked: true,
          enableVibration: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
        ),
      ],
    );

    intitialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("Action recieved!!!!!!!!!!!!!!!!!!");
    if (receivedAction.buttonKeyPressed == "ACCEPT") {
      print("accepted!!!!!!!!!!!");
      Map userMap = receivedAction.payload!;
      UserModel user = UserModel(
          id: userMap['user'],
          name: userMap['name'],
          photo: userMap['photo']
          , email: userMap['email']
      );

      CallModel call = CallModel(
        id: userMap['id'],
        channel: userMap['channel'],
        caller: userMap['caller'],
        called: userMap['called'],
        active: jsonDecode(userMap['active']),
        accepted: true,
        rejected: jsonDecode(userMap['rejected']),
        connected: true,
      );

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context){
          return VideoPage(user: user, call: call);
        }),
            (route) => (route.settings.name != '/home_screen') || route.isFirst,
      );
    }
    if (receivedAction.buttonKeyPressed == "REJECT") {
      print("called rejected!!!!!!!!!!!!!!!!!!!!");
      callsCollection.doc(receivedAction.payload!['id']).update({
        'rejected': true,
      });
    }
  }

  static Future<void> showNotification(
      {required RemoteMessage remoteMessage}) async {
    Random random = Random();
    // print(contacts);
    for(Contact contact in contacts){
      try{
        String ph = contact.phones!.first.value!.replaceAll(" ", '');
        if(ph[0]=='+') ph=ph.substring(3);

        if(ph == remoteMessage.data['caller']){
          remoteMessage.data['name'] = contact.displayName.toString();
        }
      }
      catch(e){
        continue;
      }

    }
    print("notification recieved!!!!!!!");
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: random.nextInt(1000000),
          channelKey: 'high_importance_channel',
          // largeIcon: remoteMessage.data['photo']==""? null : remoteMessage.data['photo'],
          // largeIcon: "https://search.app.goo.gl/yxW9Toq",
          title: remoteMessage.data['name'],
          body: "Incoming Video Call",
          autoDismissible: false,
          category: NotificationCategory.Call,
          notificationLayout: NotificationLayout.Default,
          locked: true,
          wakeUpScreen: true,
          backgroundColor: Colors.transparent,
          payload: {
            'user': remoteMessage.data['user'],
            'name': remoteMessage.data['name'],
            'photo': remoteMessage.data['photo'],
            'email': remoteMessage.data['email'],
            'id': remoteMessage.data['id'],
            'channel': remoteMessage.data['channel'],
            'caller': remoteMessage.data['caller'],
            'called': remoteMessage.data['called'],
            'active': remoteMessage.data['active'],
            'accepted': remoteMessage.data['accepted'],
            'rejected': remoteMessage.data['rejected'],
            'connected': remoteMessage.data['connected'],
          },
        ),
        actionButtons: [
          NotificationActionButton(
              key: "ACCEPT",
              label: 'Accept',
              color: Colors.green,
              autoDismissible: true),
          NotificationActionButton(
              key: "REJECT",
              label: "reject",
              color: Colors.red,
              autoDismissible: true),
        ]);
  }

  static Future<void> sendNotification(String token, Map data) async {
    print("SEnttt!!!!!!!!!!!!!!!!!!");
    try {
      http.Response response = await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$fcmServerKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Incoming Video Call",
              'title': 'VIDEO CALL',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              // 'id': '1',
              'status': 'done',

              'user': data['user'],
              'name': data['name'],
              'photo': data['photo'],
              'email': data['email'],
              'id': data['id'],
              'channel': data['channel'],
              'caller': data['caller'],
              'called': data['called'],
              'active': data['active'],
              'accepted': data['accepted'],
              'rejected': data['rejected'],
              'connected': data['connected'],
            },
            'to': token,
          },
        ),
      );
      response;
    } catch (e) {
      print("error : "+e.toString());
    }
  }

}
