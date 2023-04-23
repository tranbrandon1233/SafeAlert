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
import 'package:safe_alert/screens/ContactView.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
String errTxt = "";
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
   TextEditingController emailController = TextEditingController();


   @override
   void initState() {
     super.initState();
     requestPermission();
     getToken(emailController.text);
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
     try {
       await FirebaseMessaging.instance.getToken().then(
               (token) {
             setState(() {
               mtoken = token;
               print("My token is $mtoken");
             });
             saveToken(token!, email);
           }
       );
     } catch(e){
       print("ERROR: Email not found.");
     }
   }

   void saveToken(String token, String email) async {
     try {
       await FirebaseFirestore.instance.collection("users").doc(email).set(
           {'token': token
           }, SetOptions(merge: true));
     }catch(e){
       print("ERROR: Token not saved as the email was not found.");
     }
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
               const Text("Type your email here: "),
               SizedBox(
                 width: 200,
                 child: TextFormField(
                   controller: emailController,
                   maxLines: 1,
                 ),
               ),
                SizedBox(
                  height: 80,
                  child: Text(
                    errTxt,
                     selectionColor: Colors.red,
                 ),

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
             const SizedBox(
               height: 20,
             ),
                 ElevatedButton(
                     onPressed: () async {
                       String name = username.text.trim();
                       String email = emailController.text;
                      String bodyText = bodyController.text.trim().isEmpty ?  "$name sent a safety alert to you. Please check in on them as soon as you can.": bodyController.text;
                      String contactEmail = await getDataOnce_getADocument(email);
                      String titleText = "ALERT! $name might be in danger!";
                       if (name.isNotEmpty && contactEmail.trim().isNotEmpty && email.trim().isNotEmpty) {
                         try {
                           getToken(email);
                           DocumentSnapshot snap = await FirebaseFirestore
                               .instance.collection("users")
                               .doc(contactEmail)
                               .get();
                           String token = snap['token'];
                           sendPushMessage(token, bodyText, titleText);
                           setState((){errTxt = "";});

                         }
                         catch(e){
                           setState((){errTxt = "Error: Email not found.";});
                         }
                       }

                     },

                     child:

                        Container(
                          width: 150,
                          height: 20,

                          child: Center(child: const Text("Submit")),

                     )

                 )
               ],
             ),


           )
       );
     }
   }



