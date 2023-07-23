import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/countryListPage.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';
import 'package:traffic_light_detection/pages/detectionPage.dart';
import 'package:traffic_light_detection/pages/embeddedVideoPage.dart';
import 'package:traffic_light_detection/pages/locationPage.dart';
import 'package:traffic_light_detection/pages/loginPage.dart';
import 'package:traffic_light_detection/pages/profilePage.dart';
import 'package:traffic_light_detection/pages/ratingPage.dart';
import 'package:traffic_light_detection/pages/restApiPage.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  String userName=" yoour name";
  String email="someone@gmail.com";
  String  profilePictureUrl='https://i.stack.imgur.com/l60Hf.png';
  User? user=FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection("UsersInformation").doc(user?.email).get().then((value) {
      setState(() {
        userName = value.data()?["userName"];
        profilePictureUrl = value.data()?["profilePicture"];
        email=value.data()?["email"];

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("$userName",style: TextStyle(fontSize:20),),
            accountEmail: Text("$email"),
            currentAccountPicture: CircleAvatar(
              backgroundImage:( profilePictureUrl!="")?NetworkImage(profilePictureUrl!)
                  :NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.perm_camera_mic_outlined),
            title: Text("Profile"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text("Detect Traffic Light"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetectionPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.video_library),
            title: Text("Video"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmbeddedVideoPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text("Country List"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CountryListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Map"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocationPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.api_outlined),
            title: Text("Rest Api"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestApiPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text("Rateus"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RatingPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: (){
              FirebaseAuth.instance.signOut().then((value){
                print("signout");
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );

              });
            },
          ),
        ],
      ),
    );
  }
}
