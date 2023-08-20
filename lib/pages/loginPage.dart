import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';
import 'package:traffic_light_detection/pages/signupPage.dart';
import 'package:traffic_light_detection/utils/colorUtils.dart';
import '../reusable_widget/reusableWidget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _passwordTextController.dispose();
    _emailTextController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserEmailPassword();
  }
  //handle remember me function
  void _handleRemeberme(bool value) {
    _isChecked = value;
    SharedPreferences.getInstance().then(
          (prefs) {
        prefs.setBool("remember_me", value);
        prefs.setString('email', _emailTextController.text);
        prefs.setString('password', _passwordTextController.text);
      },
    );
    setState(() {
      _isChecked = value;
    });
  }
  //load email and password
  void _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;
      print(_remeberMe);
      print(_email);
      print(_password);
      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        _emailTextController.text = _email ?? "";
        _passwordTextController.text = _password ?? "";
      }
    } catch (e)
    {
      print(e);
    }
  }
  // error message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _signInWithEmailAndPassword() {
    print("entering");
    var email=_emailTextController.text;
    var password=_passwordTextController.text;
    print("$email+$password");
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async{
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DashboardPage()));
    }).catchError((error)async {
      _showSnackbar("Invalid email or password");
    });
  }

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
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
                  child: ElevatedButton(
                    onPressed: () {
                      _signInWithEmailAndPassword();
                    },
                    child: Text("LogIn",
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Colors.white;
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                      height: 24.0,
                      width: 24.0,
                      child: Theme(
                        data: ThemeData(
                            unselectedWidgetColor:Colors.white// Your color
                        ),
                        child: Checkbox(
                            activeColor: Colors.black,
                            value: _isChecked,
                            onChanged: (value){
                              _handleRemeberme(value!);
                            }
                        ),
                      )),
                  SizedBox(width: 10.0),
                  Text("Remember Me",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Rubic'))
                ]),
                SizedBox(height: 20,),

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
          style: TextStyle(color: Colors.white,fontSize:15 ,fontWeight: FontWeight.bold),
        ),
      )
    ],
  );
}