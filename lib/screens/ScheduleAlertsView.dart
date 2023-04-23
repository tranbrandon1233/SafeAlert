// ignore_for_file: unused_field
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:safe_alert/database/create_alert.dart';
import 'package:safe_alert/palatte/color_names.dart';
import 'package:safe_alert/palatte/text_styles.dart';
import 'package:safe_alert/palatte/color_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/fetch_scheduled_alerts.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;
// final User? currentUser = _auth.currentUser;
final currentUser = "IoUx5zXEYlgXqg1UVxX1BOdH3662";

class ScheduleAlertsView extends StatefulWidget {
  const ScheduleAlertsView({Key? key});

  @override
  State<ScheduleAlertsView> createState() => _ScheduleAlertsViewState();
}

class _ScheduleAlertsViewState extends State<ScheduleAlertsView> {
  final TextEditingController _alertNameController = TextEditingController();
  final TextEditingController _alertTimeController = TextEditingController();
  String alertName = "";
  late DateTime selectedTime;
//Firestore reference
  final Query<Map<String, dynamic>> _scheduledAlerts = FirebaseFirestore
      .instance
      .collection("ScheduledAlerts")
      .where("uid", isEqualTo: currentUser)
      .where("checkin", isEqualTo: false);

  // final Query<Map<String, dynamic>> _pastOrders = FirebaseFirestore.instance
  // .collection('Order Log')
  // .where('restaurantLocations', isEqualTo: userId)
  // .where('OrderStatus', isEqualTo: true);

// create new alert
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _alertNameController,
                  decoration: const InputDecoration(labelText: 'Alert Name'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _alertTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Alert Time',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Primary),
                  ),
                  child: const Text('Create'),
                  onPressed: () async {
                    final String name = _alertNameController.text;
                    final String timeString = _alertTimeController.text;
                    final DateTime now =
                        DateTime.now(); // Get current date and time
                    final String today = DateFormat('yyyy-MM-dd')
                        .format(now); // Get today's date only
                    final String completeTime =
                        '$today $timeString'; // Combine today's date with time input
                    final DateTime time = DateFormat('yyyy-MM-dd HH:mm')
                        .parse(completeTime); // Parse as DateTime
                    final Timestamp firestoreTimestamp =
                        Timestamp.fromDate(time);
                    // final DateTime time = DateFormat("hh:mm").parse(timeString);
                    // final Timestamp firestoreTimestamp =
                    //     Timestamp.fromDate(time);

                    await FirebaseFirestore.instance
                        .collection("ScheduledAlerts")
                        .add({
                      "AlertName": name,
                      "Time": firestoreTimestamp,
                      "uid": currentUser,
                      "checkin": false
                    });

                    _alertNameController.text = '';
                    _alertTimeController.text = '';
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 100,
                  width: 200,
                  child: Image(
                    image: AssetImage("images/scheduledalertstitle.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => {_create()},
                  icon: Icon(
                    Icons.add,
                    color: Colors.red,
                  ),
                  label: Text("Create New Alert"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Primary),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
            stream: _scheduledAlerts.snapshots(),
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                final documents = streamSnapshot.data!.docs;
                return ListView.builder(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      final Time = document['Time'];
                      final alertName = document['AlertName'];

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16.0), // Set the desired border radius
                                ),
                                title: Text(
                                  "Alert Details",
                                  style: TextStyle(color: Colors.red),
                                ),
                                content: Container(
                                  width: 400,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      Text("Alert Name: $alertName"),
                                      Text("Alert Time: ${DateFormat('MM-dd-yyyy').format(Time.toDate())}" +
                                          "  "
                                              "${DateFormat('hh:mm').format(Time.toDate())}"),
                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.black),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                    child: Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                    child: Text("Cancel Alert"),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("ScheduledAlerts")
                                          .doc(document
                                              .id) // Assuming document.id represents the document ID of the alert to be cancelled
                                          .update({
                                        "checkin": true
                                      }) // Update the 'checkin' field to true
                                          .then((value) {
                                        // Success
                                        print("Alert cancelled successfully");
                                        Navigator.of(context).pop();
                                      }).catchError((error) {
                                        // Error
                                        print("Failed to cancel alert: $error");
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 300,
                          height: 100,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.red, width: 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text("$alertName"),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                      "${DateFormat('MM-dd-yyyy').format(Time.toDate())}" +
                                          "  "
                                              "${DateFormat('hh:mm').format(Time.toDate())}"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                // Return a placeholder widget or loading spinner when data is not available
                return const CircularProgressIndicator(
                  color: Colors.red,
                );
              }
            },
          ))
        ],
      )),
    );
  }
}
