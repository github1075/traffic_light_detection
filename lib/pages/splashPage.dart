import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';
import 'package:traffic_light_detection/pages/loginPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  // this is for tween animation
  late Animation colorAnimation;
  late AnimationController animationController;
  @override
  initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds:2),(){
     Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>LoginPage()));
    });
    animationController=AnimationController(vsync: this,duration:Duration(seconds:2));
    colorAnimation= ColorTween(begin: Colors.white,end: Colors.yellow).animate(animationController);
    colorAnimation.addListener(() {
      setState(() {

      });
    });
    animationController.forward();
  }

  @override
  void dispose() {
    // Dispose the AnimationController to prevent memory leaks
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration:BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/traffic_bacground2.jpeg'),
              fit: BoxFit.cover
            )
          ),
          child: Center(
            child: Column(
              children: [
                SizedBox(height:220,),
                Container(
                  color:Colors.black45,
                  child: SizedBox(
                      width: 250.0,
                      child: Text("Welcome",
                        style: TextStyle(
                            color:colorAnimation.value,
                            fontWeight: FontWeight.bold,
                            fontSize:50),)
                  ),
                ),
                SizedBox(
                  height:220,
                ),
                SpinKitCircle(
                  color: Colors.white,
                  size: 50.0,
                )
              ],
            )
          )
        ),
    );
  }
}


