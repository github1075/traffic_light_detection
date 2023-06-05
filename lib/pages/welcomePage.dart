import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:traffic_light_detection/pages/loginPage.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
     Timer(Duration(seconds:2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
            child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/traffic_bacground2.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top:200, bottom: 12),
                  child: Text(
                    "Traffic Light Detection App",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        backgroundColor:Colors.black38,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height:320,
                ),
                SpinKitCircle(
                  color: Colors.white,
                  size: 50.0,
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
