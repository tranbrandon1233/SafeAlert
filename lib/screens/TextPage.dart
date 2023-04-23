import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:safe_alert/screens/FullText.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();
const String navigationActionId = 'id_3';
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print

  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class TextPage extends StatefulWidget {
  const TextPage({Key? key}) : super(key: key);
  @override
  State<TextPage> createState() => _TextPageState();
}

 class _TextPageState extends State<TextPage> {
   String? mtoken = " ";
   FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
   TextEditingController username = TextEditingController();
   TextEditingController bodyController = TextEditingController();

   @override
   void initState() {
     super.initState();
     requestPermission();
     getToken(username.text);
     initInformation();
   }

   initInformation() {
     //String payload = "";
     var androidInitialize = const AndroidInitializationSettings(
         '@mipmap/ic_launcher');
     var iOSInitialize = const DarwinInitializationSettings();
     var initSettings = InitializationSettings(
         android: androidInitialize, iOS: iOSInitialize);
     flutterLocalNotificationPlugin.initialize(
       initSettings, onDidReceiveNotificationResponse:
         (NotificationResponse notificationResponse) {
       try{
         switch (notificationResponse.notificationResponseType) {
           case NotificationResponseType.selectedNotification:
             selectNotificationStream.add(notificationResponse.payload);
             //payload = notificationResponse.payload.toString();
             Navigator.push(
                 context, MaterialPageRoute(builder: (BuildContext context) {
               return FullText(info: notificationResponse.payload.toString());
             }));
             break;
           case NotificationResponseType.selectedNotificationAction:
             if (notificationResponse.actionId == navigationActionId) {
               selectNotificationStream.add(notificationResponse.payload);
               //payload = notificationResponse.payload.toString();
               Navigator.push(
                   context, MaterialPageRoute(builder: (BuildContext context) {
                 return FullText(info: notificationResponse.payload.toString());
               }));
             }
             break;
         }
       }
       catch(e) {

       }
         return;
     },
       onDidReceiveBackgroundNotificationResponse: notificationTapBackground);
     /*
         Navigator.push(
             context, MaterialPageRoute(builder: (BuildContext context) {
           return FullText(info: payload);
         }));*/


     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
       print("..................onMessage....................");
       print("onMessage: ${message.notification?.title}/${message.notification
           ?.body}}");

       BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
         message.notification!.body.toString(), htmlFormatBigText: true,
         contentTitle: message.notification!.title.toString(),
         htmlFormatContentTitle: true,
       );
       AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
         'dbfood', 'dbfood', importance: Importance.high,
         styleInformation: bigTextStyleInformation,
         priority: Priority.high,
         playSound: true,
       );
       NotificationDetails platformChannelSpecifics = NotificationDetails(
           android: androidPlatformChannelSpecifics,
           iOS: const DarwinNotificationDetails());

       await flutterLocalNotificationPlugin.show(
           0, message.notification?.title, message.notification?.body,
           platformChannelSpecifics, payload: message.data['body']);
     });
   }

   void getToken(String email) async {
     await FirebaseMessaging.instance.getToken().then(
             (token) {
           setState(() {
             mtoken = token;
             print("My token is $mtoken");
           });
           saveToken(token!, email);
         }
     );
   }

   void saveToken(String token, String email) async {
     await FirebaseFirestore.instance.collection("UserTokens").doc(email).set(
         {'token': token});
   }

   void requestPermission() async {
     FirebaseMessaging messaging = FirebaseMessaging.instance;

     NotificationSettings settings = await messaging.requestPermission(
         alert: true,
         announcement: false,
         badge: true,
         carPlay: false,
         criticalAlert: true,
         provisional: false,
         sound: true
     );
     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
       print('User granted permission');
     } else
     if (settings.authorizationStatus == AuthorizationStatus.provisional) {
       print('User granted provisional permission');
     } else {
       print('User declined or has not accepted permission.');
     }
   }

   void sendPushMessage(String token, String body, String title) async {
     try {
       await http.post(
         Uri.parse('https://fcm.googleapis.com/fcm/send'),
         headers: <String, String>{
           'Content-Type': 'application/json',
           'Authorization': 'key=AAAAwGeS5kI:APA91bHhJsD4rplqy-kepfyibb-yB-EJu9zc3wyo52SwmLiDAb97ZA39YqIWZ4Ul8hXlsQ7nok-UfrMffjLx6UNsXI77jZP-KZusuvRRZaKUQH6rUq5tWTztf3U00kWh44yNxe36N2I9'
         },
         body: jsonEncode(
           <String, dynamic>{

             'priority': 'high',
             'data': <String, dynamic>{
               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
               'status': 'done',
               'body': body,
               'title': title,
             },

             "notification": <String, dynamic>{
               "title": title,
               "body": body,
               "android_channel_id": "dbfood"
             },
             "to": token
           },
         ),
       );
     } catch (e) {
       if (kDebugMode) {
         print("Error push notification");
       }
     }

     void getForegroundMsg() {
       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
         print('Got a message whilst in the foreground!');
         print('Message data: ${message.data}');

         if (message.notification != null) {
           print('Message also contained a notification: ${message
               .notification}');
         }
       });
     }
   }
     @override
     build(BuildContext context) {
       return Scaffold(
           body: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const Text("Type your name here: "),
                 SizedBox(
                   width: 200,
                   child: TextFormField(
                     controller: username,
                     maxLines: 1,
                   ),
                 ),
                 const SizedBox(
                   height: 80,

                 ),
                 const Text("Customize your emergency text here: "),
                 SizedBox(
                   height: 80,
                   width: 400,
                   child:
                   TextFormField(
                     controller: bodyController,
                     minLines: 3,
                     maxLines: 5,
                   ),
                 ),
                 GestureDetector(
                     onTap: () async {
                       String name = username.text.trim();
                      String bodyText = bodyController.text.trim().isEmpty ?  "$name sent a safety alert to you. Please check in on them as soon as you can.": bodyController.text;
                      String titleText = "ALERT! $name might be in danger!";
                       if (name != "") {
                         try {
                           DocumentSnapshot snap = await FirebaseFirestore
                               .instance.collection("UserTokens")
                               .doc(name)
                               .get();
                           String token = snap['token'];
                           print(token);
                           sendPushMessage(token, bodyText, titleText);
                         }
                         catch(e){
                           print("Error: User not found.");
                         }
                       }
                     },
                     child: Container(
                       margin: const EdgeInsets.all(20),
                       height: 20,
                       width: 100,
                       decoration: BoxDecoration(
                           color: Colors.red,
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.redAccent.withOpacity(0.5),
                             )
                           ]
                       ),
                       child: Center(child: const Text("Submit")),
                     )
                 )
               ],
             ),


           )
       );
     }
   }



