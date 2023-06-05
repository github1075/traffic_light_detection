import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/homePage.dart';
import 'package:traffic_light_detection/reusable_widget/reusableWidget.dart';
import 'package:traffic_light_detection/utils/colorUtils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'SignUp',
          style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
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
              children: [
                SizedBox(
                  height: 20,
                ),
                reusableTextField("enter your username",
                    Icons.person_2_outlined, false, _userNameTextController),
                SizedBox(
                  height: 20,
                ),
                reusableTextField("enter your email", Icons.email_outlined,
                    false, _emailTextController),
                SizedBox(
                  height: 20,
                ),
                reusableTextField("enter your password", Icons.lock_outline,
                    true, _passwordTextController),
                SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "SignUp", () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    print("Account created");
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homepage()));
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
