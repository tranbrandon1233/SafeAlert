import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:location/location.dart';

CollectionReference users = FirebaseFirestore.instance.collection('users');
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;

//  Future<void> updateCurrentLocation () {
//     GeoPoint loc = GeoPoint(currentLoc!.latitude!, currentLoc!.longitude!);

//     return users.doc(user?.email)
//       //updating grade value of a specific student
//       .set({
//         'currentLocation': loc,
//       }, SetOptions(merge: true))
//       .then((value) => print("Phone Number Updated"))
//       .catchError((error) => print("Failed to update data"));
//   }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  LocationData? currentLoc;
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
        onPressed: () => print("Helllo"),
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
    getCurrentLocation();
  }

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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Hello',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            _buildGoogleMap(context),
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
      ),
    );
  }
}
