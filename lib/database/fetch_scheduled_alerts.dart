// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:safe_alert/database/create_alert.dart';
// import 'package:safe_alert/palatte/color_names.dart';
// import 'package:safe_alert/palatte/text_styles.dart';
// import 'package:safe_alert/palatte/color_names.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ScheduledAlertsStreamBuilder extends StatelessWidget {
//   final String userId; // User ID
//   ScheduledAlertsStreamBuilder({required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       stream: FirebaseFirestore.instance
//           .collection('user')
//           .doc(userId)
//           .collection('scheduled_alerts')
//           .snapshots(),
//       builder: (BuildContext context,
//           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }

//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Text('No data available');
//         }

//         // Access the subcollection data
//         List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
//             snapshot.data!.docs;
//         return ListView.builder(
//           itemCount: documents.length,
//           itemBuilder: (BuildContext context, int index) {
//             // Access the data of each subcollection document
//             Map<String, dynamic> data = documents[index].data();
//             return ListTile(
//               title: Text('Document ID: ${documents[index].id}'),
//               subtitle: Text('Data: $data'),
//             );
//           },
//         );
//       },
//     );
//   }
// }
