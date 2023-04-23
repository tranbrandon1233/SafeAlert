import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safe_alert/firebase_options.dart';
import 'package:safe_alert/screens/home_screen.dart';
import 'screens/TextPage.dart';
import 'screens/LogIn.dart';

Future<void> _firebaseMessagingbackgroundHandler(RemoteMessage message) async{
  print("Handling a background message ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingbackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currContact = -1;

  void _updateContact(int newContact) {
    setState(() {
      this._currContact = newContact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: ContactView(update: _updateContact),
      home:  const HomeScreen(),
    );
  }
}

