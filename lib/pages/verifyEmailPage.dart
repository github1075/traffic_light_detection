import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';

import '../utils/colorUtils.dart';


class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});


  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}
final _auth=FirebaseAuth.instance;
User? user;
Timer? timer;

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user=_auth.currentUser;
    user!.sendEmailVerification();
    timer=Timer.periodic(Duration(seconds:2), (timer) {
      checkEmailVerification();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("5C2774"),
              hexStringToColor("335CC5"),
              hexStringToColor("637FFD"),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("An email has been sent")

              ],
            ),
          ),
        ),
      ),


    );
  }
  Future<void> checkEmailVerification()async{
    User? user=FirebaseAuth.instance.currentUser;
    await user!.reload();
    if(user.emailVerified){
      timer!.cancel();
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>DashboardPage()));
    }

}

}
