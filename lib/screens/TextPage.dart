import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class TextPage extends StatefulWidget {
  const TextPage({Key? key}) : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  String? mtoken = " ";
  TextEditingController name = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState(){
    super.initState();
    requestPermission();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then(
            (token) {
          setState((){mtoken = token;
          print("My token is $mtoken");
          });
          saveToken(token!);
        }
    );
  }

  void saveToken(String token) async{
    await FirebaseFirestore.instance.collection("UserTokens").doc("User1").set({'token': token});
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
    if (settings.authorizationStatus == AuthorizationStatus.authorized){
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional){
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission.');
    }
  }
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
                  controller: name,
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
                  controller: body,
                  minLines: 3,
                  maxLines: 5,
              ),
              ),
              GestureDetector(
                onTap: () async {
                  String nameText = name.text.trim();
                  String bodyText = body.text;
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
