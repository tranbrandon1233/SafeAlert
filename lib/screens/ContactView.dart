import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safe_alert/screens/LogIn.dart';

CollectionReference users = FirebaseFirestore.instance.collection('users');
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = (user != null ? user?.uid : '');

String? getDataOnce_getADocument() {
  final docRef =
      FirebaseFirestore.instance.collection("users").doc(user?.email);
  docRef.get().then(
    (DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['email']?.toString();
    },
    onError: (e) => print("Error getting document: $e"),
  );
  return null;
}

//For updating docs, you can use this function.
Future<void> updateUserPhone(String? number) {
  return users
      //referring to document ID, this can be queried or named when added accordingly
      .doc(user?.email)
      //updating grade value of a specific student
      .set({
        'phone': number ?? "",
        'user': (user != null ? user?.email : ""),
        'uid': uid
      }, SetOptions(merge: true))
      .then((value) => print("Phone Number Updated"))
      .catchError((error) => print("Failed to update data"));
}

Future<void> updateUserEmail(String? email) {
  return users
      //referring to document ID, this can be queried or named when added accordingly
      .doc(user?.email)
      //updating grade value of a specific student
      .set({'email': email ?? ""}, SetOptions(merge: true))
      .then((value) => print("Email Updated"))
      .catchError((error) => print("Failed to update data"));
}

Future<void> _signOut() async {
  await FirebaseAuth.instance.signOut();
}

class ContactView extends StatefulWidget {
  final ValueChanged<int> update;
  ContactView({required this.update});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Contact List"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              _signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            }, //widget.update(index), // Passing value to the parent widget.
            child: const Text('Sign Out'),
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        child: FutureBuilder(
          future: getContacts(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: SizedBox(height: 50, child: CircularProgressIndicator()),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  Contact contact = snapshot.data[index];
                  return Column(children: [
                    ListTile(
                      leading: const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person),
                      ),
                      title: Text(contact.displayName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          contact.phones.isNotEmpty
                              ? Text(contact.phones[0])
                              : const Text(''),
                          contact.emails.isNotEmpty
                              ? Text(contact.emails[0])
                              : const Text(''),
                          ElevatedButton(
                            onPressed: () => {
                              updateUserPhone(contact.phones.isNotEmpty
                                  ? contact.phones[0]
                                  : ""),
                              updateUserEmail(contact.emails.isNotEmpty
                                  ? contact.emails[0]
                                  : "")
                            }, //widget.update(index), // Passing value to the parent widget.
                            child: const Text('Make My Contact'),
                          )
                        ],
                      ),
                    ),
                    const Divider()
                  ]);
                });
          },
        ),
      ),
    );
  }
}

Future<List<Contact>> getContacts() async {
  bool isGranted = await Permission.contacts.status.isGranted;
  if (!isGranted) {
    isGranted = await Permission.contacts.request().isGranted;
  }
  if (isGranted) {
    return await FastContacts.allContacts;
  }
  return [];
}
