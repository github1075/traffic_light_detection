import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/homePage.dart';
import 'package:traffic_light_detection/pages/signupPage.dart';
import 'package:traffic_light_detection/utils/colorUtils.dart';

import '../reusable_widget/reusableWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("5C2774"),
          hexStringToColor("335CC5"),
          hexStringToColor("637FFD"),
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * .2, 20, 0),
            child: Column(
              children: [
                logoWidget("images/traffic_light2.png"),
                SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter your email", Icons.email_outlined,
                    false, _emailTextController),
                SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter your password", Icons.lock_outline,
                    true, _passwordTextController),
                SizedBox(
                  height: 20,
                ),
                firebaseUIButton(context, "LogIn", () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Homepage()));
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                }),
                SizedBox(
                  height: 10,
                ),
                signupOption(context)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Row signupOption(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have account?",
          style: TextStyle(color: Colors.white70)),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignupPage()));
        },
        child: const Text(
          " Sign Up",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}
