import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traffic_light_detection/pages/loginPage.dart';
import 'package:traffic_light_detection/pages/verifyEmailPage.dart';

import 'package:traffic_light_detection/reusable_widget/reusableWidget.dart';
import 'package:traffic_light_detection/utils/colorUtils.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isEmailValid=false;
  bool isUniqueUserName=true;
  bool isSelectImage=false;
  User? user;
  Uint8List? _image,im;
  String? photoUrl;

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _birthdateTextController=TextEditingController();
  //set profile image
  selectImage() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {

        im =await file.readAsBytes();
        setState(() {
          _image=im;
          isSelectImage=true;
        });

    }

  }


  // adding image to firebase storage
  Future<void> uploadImageToStorage(String childName, Uint8List file,String email) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    Reference ref = _storage.ref().child(childName).child("$email");
    UploadTask uploadTask = ref.putData(file);

    uploadTask.snapshotEvents.listen((event) async {
      if (event.state == TaskState.success) {
        String downloadUrl = await event.ref.getDownloadURL();
        setState(() {
          photoUrl = downloadUrl;
          setUserCollection();
          print("photo=$photoUrl and down=$downloadUrl");
        });
      }
    });
  }
  Future<void> loadImage() async {
    print("load is");
    final response = await http.get(Uri.parse('https://i.stack.imgur.com/l60Hf.png'));
    final bytes = response.bodyBytes;
    final email = user?.email; // Replace with the user's UID
    final storageRef = FirebaseStorage.instance.ref().child('profilePics/$email');
    final uploadTask = storageRef.putData(bytes);

    uploadTask.snapshotEvents.listen((event) async {
      if (event.state == TaskState.success) {
        String downloadUrl = await event.ref.getDownloadURL();
        setState(() {
          photoUrl = downloadUrl;
          setUserCollection();
          print("photo=$photoUrl and down=$downloadUrl");
        });
      }
    });
  }
  // user collection create in the firebase database then go to verification page
  void setUserCollection(){
    var email,userName,password,birthdate,userId;
    email=_emailTextController.text.trim().toString();
    userName=_userNameTextController.text.trim().toString();
    password=_passwordTextController.text.trim().toString();
    birthdate=_birthdateTextController.text.trim().toString();
    userId=user?.uid.toString();
    FirebaseFirestore.instance.collection("UsersInformation").doc(email).set({
      "userName":userName,
      "email":email,
      "password":password,
      "birthdate":birthdate,
      "userId":userId,
      "profilePicture":photoUrl
    });
    print("user collection");
    //go to verifyemail page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) =>VerifyEmailPage()));
  }
// dispose all controllers
  @override
  void dispose() {
    super.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _userNameTextController.dispose();
    _birthdateTextController.dispose();
  }
// multiple dependent dropdown manu
  List<dynamic>divisions=[];
  String? districtId;
  //multiple dropdownmanue

  String? _division;
  String? _district;

  final List<String> _divisions = ['Dhaka', 'Chittagong', 'Rajshahi', 'Khulna', 'Barisal', 'Sylhet', 'Rangpur', 'Mymensingh'];

  final Map<String, List<String>> _districts = {
    'Barisal': ['Barguna', 'Barisal', 'Bhola', 'Jhalokati', 'Patuakhali', 'Pirojpur'],
    'Chittagong': ['Bandarban', 'Brahmanbaria', 'Chandpur', 'Chittagong', 'Comilla', 'Cox\'s Bazar', 'Feni', 'Khagrachhari', 'Lakshmipur', 'Noakhali', 'Rangamati'],
    'Dhaka': ['Dhaka', 'Faridpur', 'Gazipur', 'Gopalganj', 'Kishoreganj', 'Madaripur', 'Manikganj', 'Munshiganj', 'Narayanganj', 'Narsingdi', 'Rajbari', 'Shariatpur'],
    'Khulna': ['Bagerhat','Chuadanga','Jessore','Jhenaidah','Khulna','Kushtia','Magura','Meherpur','Narail','Satkhira'],
    'Mymensingh': ['Jamalpur','Mymensingh','Netrokona','Sherpur'],
    'Rajshahi': ['Bogra','Chapainawabganj','Joypurhat','Naogaon','Natore','Pabna','Rajshahi','Sirajganj'],
    'Rangpur': ['Dinajpur','Gaibandha','Kurigram','Lalmonirhat','Nilphamari','Panchagarh','Rangpur','Thakurgaon'],
    'Sylhet': ['Habiganj','Moulvibazar','Sunamganj','Sylhet']
  };


  // check useerName function
 void isUniqueUserNameQuery(String userName) async {
  final result=await FirebaseFirestore.instance.collection('UsersInformation').where('userName',isEqualTo: userName).get();
  setState(() {
    isUniqueUserName=result.docs.isEmpty;
  });
  print("$isUniqueUserName");
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            padding: EdgeInsets.fromLTRB(20,80, 20, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                    "SignUp",
                style: TextStyle(
                  color: Colors.white,
                  fontSize:30,
                  fontWeight: FontWeight.bold,
                ),
                ),
                SizedBox(height:30 ,),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(_image!),
                      backgroundColor: Colors.white30,
                    )
                        : const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://i.stack.imgur.com/l60Hf.png'),
                      backgroundColor: Colors.black45,
                    ),
                    Positioned(
                      bottom: -8,
                      left: 65,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo,color:Colors.black,),
                      ),
                    )
                  ],
                ),
                SizedBox(height:30 ,),
                TextField(
                  controller: _userNameTextController,
                  obscureText: false,
                  enableSuggestions:true,
                  autocorrect:true,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  autofillHints:[AutofillHints.email],
                  onChanged: (value){

                      setState((){
                        if(value.isNotEmpty){
                          isUniqueUserNameQuery(value.trim().toString());
                        }
                      });
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
                    labelText: "username",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                  ),
                  keyboardType: TextInputType.text
                ),
                if(!isUniqueUserName && _userNameTextController.text.toString().isNotEmpty)
                  Text("not unique")
                else if(isUniqueUserName && _userNameTextController.text.toString().isNotEmpty) Text("unique")
                ,

                SizedBox(
                  height: 20,
                ),
                TextField(
                    controller: _emailTextController,
                    obscureText: false,
                    enableSuggestions:true,
                    autocorrect:true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    onChanged: (String email){
                      setState(() {
                        isEmailValid=isEmail(email);
                        if(isEmailValid==true){
                        }
                      });

                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      suffixIcon:_emailTextController.text.isEmpty ?null
                      :(isEmailValid? Icon(Icons.done,color: Colors.green[900],)
                          :Icon(Icons.close_sharp,color: Colors.red[900],)),
                      labelText: "email",
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                      hintText: "someone@example.com",
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.emailAddress
                ),

                SizedBox(
                  height: 20,
                ),
                TextField(
                    controller:_passwordTextController,
                    obscureText: true,
                    enableSuggestions:false,
                    autocorrect:false,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      labelText: "password",
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.visiblePassword
                ),
                SizedBox(height: 20,),
                TextField(
                    controller:_birthdateTextController,
                    obscureText:false,
                    enableSuggestions:true,
                    autocorrect:true,
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    onTap: ()async{
                      DateTime? pickedDate= await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate:DateTime.now()
                      );
                      if(pickedDate !=null){
                        setState(() {
                          _birthdateTextController.text= formatDate(pickedDate, [dd, '-', mm, '-', yyyy]);
                        });

                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.date_range_outlined,
                        color: Colors.white,
                      ),
                      labelText: "birthdate",
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                    ),
                    keyboardType: TextInputType.datetime
                ),
                SizedBox(height: 20,),
//multiple dropdownmanue
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Division',style: TextStyle(fontSize:15 ,color:Colors.white.withOpacity(0.9) ),),
                      DropdownButtonFormField(
                        value: _division,
                        decoration: InputDecoration(

                          hintText:'Select you division',
                          prefixIcon: Icon(Icons.edit_location_alt_outlined,color: Colors.white.withOpacity(0.6),)
                        ),
                        items: _divisions.map((division) {
                          return DropdownMenuItem(
                            value: division,
                            child: Text('$division'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _division = value;
                            _district = null;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Text('District',style: TextStyle(fontSize:15 ,color:Colors.white.withOpacity(0.9) ),),
                      DropdownButtonFormField(
                        value: _district,
                        decoration: InputDecoration(

                            hintText:'Select you district',
                            prefixIcon: Icon(Icons.location_city_outlined,color: Colors.white.withOpacity(0.6),)
                        ),
                        items: _districts[_division]?.map((district) {
                          return DropdownMenuItem(
                            value: district,
                            child: Text('$district'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _district = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 40,),
                //signupbutton
                firebaseUIButton(context, "SignUp", (){
                  //authentication
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value){
                    print("Account created");
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });

                  //Checking fields are null or not
                  var email,userName,password,birthdate,userId;
                  email=_emailTextController.text.trim().toString();
                  userName=_userNameTextController.text.trim().toString();
                  password=_passwordTextController.text.trim().toString();
                  birthdate=_birthdateTextController.text.trim().toString();
                  user= FirebaseAuth.instance.currentUser;
                  userId=user?.uid.toString();
                  print("your id="+userId);
                  if((email !=""|| !email.isNulll)&&(password!=""|| !password.isNull)&&(birthdate!=""|| !birthdate.isNull)&&(userName!=""|| !userName.isNull)){

                    //profile image section and then create collection
                    print("all ok");
                    if(!isSelectImage) {
                      loadImage();
                    }
                    else{
                       uploadImageToStorage('profilePics', _image!,email);
                    }

                  }

                }),
            SizedBox(height:10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account",
                    style: TextStyle(color: Colors.white70)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) =>LoginPage()));
                  },
                  child: const Text(
                    " LognIn",
                    style: TextStyle(color: Colors.white,fontSize:15, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),

                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
