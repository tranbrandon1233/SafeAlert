import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:safe_alert/screens/FullText.dart';
import 'package:safe_alert/screens/ContactView.dart';
import 'package:safe_alert/screens/LogIn.dart';


CollectionReference users = FirebaseFirestore.instance.collection('users');
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  LocationData? currentLoc;
  String? mtoken = " ";
  FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  TextEditingController username = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);

  // bool _serviceEnabled;
  // PermissionStatus _permissionGranted;
  // LocationData _locationData;

  Future<void> getCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    print("Get current location before ");
    print(currentLoc);
    _locationData = await location.getLocation();
    setState(() {
      currentLoc = _locationData;
      print('current location after setting location');
      print(currentLoc!.longitude!);
      print(currentLoc!.latitude!);
    });
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

  Future<void> updateCurrentLocation () {
    GeoPoint loc = GeoPoint(currentLoc!.latitude!, currentLoc!.longitude!);

    return users.doc(user?.email)
      //updating grade value of a specific student
      .set({
        'currentLocation': loc,
      }, SetOptions(merge: true))
      .then((value) => print("Phone Number Updated"))
      .catchError((error) => print("Failed to update data"));

  }

  void sendEmergencyMessage () async {
    String name = username.text.trim();
    String email = emailController.text;
    String bodyControllText = bodyController.text;
    String latitude = currentLoc!.latitude!.toString();
    String longitude = currentLoc!.longitude!.toString();

    String bodyText = bodyController.text.trim().isEmpty ?  "$name sent a safety alert to you. Please check in on them as soon as you can. " : "$bodyControllText . Location: ($latitude, $longitude)";
    String contactEmail = await getDataOnce_getADocument(email);
    updateCurrentLocation();
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

  }


  Widget _buildGoogleMap(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return currentLoc == null ?
          const Center(child: Text("Loading Location..."),)
          :
          ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      child: Container(
        width: size.width,
        height: size.height * 0.3,
        child:  GoogleMap(initialCameraPosition: CameraPosition(
          target: LatLng(currentLoc!.latitude!, currentLoc!.longitude!),  // Set the initial map position
          zoom: 14.0,  // Set the initial zoom level

          ),
          compassEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of([
            Marker(
            markerId: MarkerId("currentLocation"),
            position: LatLng(currentLoc!.latitude!, currentLoc!.longitude!)
          ),

        ]),
      ),
    ));
  }


  Widget _buildButton(BuildContext context, Color color) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: ElevatedButton(
        onPressed: () => sendEmergencyMessage(),
        child:  const Text(
          'Send Emergency Message',
          style: TextStyle(
            // color: Colors.black,
            fontSize: 18,
            fontFamily: 'Be Vietnam'
          ),
        ),
      )
    );

  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken(emailController.text);
    getCurrentLocation();
  }

  final List<BottomNavigationBarItem> bottomNavBarItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.contact_phone ),
      label: 'Contacts',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.login ),
      label: 'Login',
    ),
  ];

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

//   PageView(
//   controller: _pageController,
//   children: [
//     // Pages to display for each bottom navigation bar item
//     HomeScreen(),
//     ContactView(),
//     LoginScreen(),
//   ],
//   onPageChanged: _onPageChanged, // Optional: handler for page change
// )

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("hello"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            _buildGoogleMap(context),
            const Text("Type your name here: "),
            SizedBox(
              width: 200,
              child: TextFormField(
                controller: username,
                maxLines: 1,
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
            _buildButton(context, Colors.black)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("Hello"),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.abc_sharp),
          ),
          BottomNavigationBarItem(
            label: "Add Alert",
            icon: Icon(Icons.add),
          )
        ],
        onTap: _onItemTapped,
        // mouseCursor: _selectedIndex,


      ),
    );
  }
}
