import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/loginPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              print("Signout");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            });
          },
          child: Text(
            "Logout",
          ),
        ),
      ),
    );
  }
}
