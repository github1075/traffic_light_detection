import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _emailTextController=TextEditingController();
  late TextEditingController _passwordTextController=TextEditingController();
  late TextEditingController _userNameTextController=TextEditingController();
  late TextEditingController _birthdateTextController=TextEditingController();

  Uint8List? _image, im;
  User? user=FirebaseAuth.instance.currentUser;
  bool isUniqueUserName=true;
  bool isUserNameEmpty = false;
  bool isPasswordEmpty = false;
  bool isPasswordValid=true;
  bool isPasswordVisible=false;
  bool isUpdating=false;
  String userName ="name";
  String retrievedEmail ="email";
  String password ="password";
  String birthdate ="date";
  String? profilePicture;
  String? photoUrl;
  String email="someone@gmail.com";


  @override
  void initState() {
    email=(user?.email).toString();
    print("yes i am:$email");
    // TODO: implement initState
    super.initState();
    fetchUserData(email);
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
  void fetchUserData(String email) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("UsersInformation")
          .doc(email)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          userName = data["userName"];
          retrievedEmail = data["email"];
          password = data["password"];
          birthdate = data["birthdate"];
          profilePicture = data["profilePicture"];

          _userNameTextController = TextEditingController(text: userName);
          _birthdateTextController = TextEditingController(text: birthdate);
          _passwordTextController = TextEditingController(text: password);
        });


         print("$userName+$password");
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void selectImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery);

    if (file != null) {
      im = await file.readAsBytes();
      setState(() {
        _image = im;
        uploadImageToStorage(_image!);
      });
    }
  }
  // unique username
  void isUniqueUserNameQuery(String name) async {
    print("enter name check");
    final result=await FirebaseFirestore.instance.collection('UsersInformation').where('userName',isEqualTo:name).where('email',isNotEqualTo:email).get();
    setState(() {
      isUniqueUserName=result.docs.isEmpty;
    });
    print("$isUniqueUserName");
  }
  // update profile
  void updateProfile() async {
    setState(() {
      isUserNameEmpty = _userNameTextController.text.trim().isEmpty;
      isPasswordEmpty = _passwordTextController.text.trim().isEmpty;

      if (isUserNameEmpty || isPasswordEmpty || !isPasswordValid) {
        // Show the alert dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Rules:\n1.Username or Password can't be null\n2.Password should be at least 6 characters"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          isUpdating = true;
        });

        try {
         changeFirebaseAuthPass();

      setState(() {
      isUpdating = false;
      });

      // Show the success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: Text("Profile updated successfully"),
      duration: Duration(seconds: 3),
      ),
      );
      } catch (error) {
      setState(() {
      isUpdating = false;
      });

      // Show the error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: Text("Error updating profile"),
      duration: Duration(seconds: 3),
      ),
      );
      }
    }
    });
  }
  // upload image
  // adding image to firebase storage
  Future<void> uploadImageToStorage(Uint8List file) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    Reference ref = _storage.ref().child("profilePics").child("$email");
    UploadTask uploadTask = ref.putData(file);

    uploadTask.snapshotEvents.listen((event) async {
      if (event.state == TaskState.success) {
        String downloadUrl = await event.ref.getDownloadURL();
        setState(() {
          photoUrl = downloadUrl;
          print("photo=$photoUrl and down=$downloadUrl");
          FirebaseFirestore.instance.collection("UsersInformation").doc(email).update({
            "profilePicture": photoUrl,
          });
          FirebaseFirestore.instance.collection("statuses").doc(email).update({
            "profilePicture":photoUrl,
          });
        });
      }
    });
  }
  //UserInformation
  Future<void> userInfoUpdate()async {
//
    await FirebaseFirestore.instance.collection("UsersInformation")
        .doc(email)
        .update({
      "userName": _userNameTextController.text.trim(),
      "password": _passwordTextController.text.trim(),
      "birthdate": _birthdateTextController.text.trim(),
    });
    print("entering");
    await FirebaseFirestore.instance.collection("statuses").doc(email).update({
      "userName": _userNameTextController.text.trim(),
    });
  }
  changeFirebaseAuthPass() async {
    try {
      String newPass = _passwordTextController.text.trim();
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password, // Use the user's current password
      );

      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPass);

      // Password updated successfully
      userInfoUpdate();

    } catch (error) {
      // An error occurred
      print("Error changing password: $error");

      // Show the error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating password"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Colors.indigo[400], // Adjust the background color
        elevation: 1, // Add a subtle elevation for depth
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(160),
          child: Align(
            alignment: Alignment.bottomCenter, // Center the Stack within the AppBar
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20), // Add space at the bottom
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _image != null
                      ? CircleAvatar(
                    radius: 70,
                    backgroundImage: MemoryImage(_image!),
                    backgroundColor: Colors.white30,
                  )
                      : CircleAvatar(
                    radius: 70,
                    backgroundImage: profilePicture != null &&
                        profilePicture!.isNotEmpty
                        ? NetworkImage(profilePicture!)
                        : NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
                    backgroundColor: Colors.black45,
                  ),
                  Positioned(
                    bottom:3,
                    left: 95,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black54,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.add_a_photo, color: Colors.white, size: 25),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              shape: CircleBorder(),
                              child: InkWell(
                                onTap: selectImage,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              TextField(
                  controller: _userNameTextController,
                  obscureText: false,
                  enableSuggestions:true,
                  autocorrect:true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black.withOpacity(0.9)),
                  autofillHints:[AutofillHints.name],
                  onChanged: (value){
                    print("yes");
                      if(value.toString().trim().isNotEmpty){
                        isUniqueUserNameQuery(value.toString().trim());
                        setState(() {
                          isUserNameEmpty = false;
                        });

                      }
                      else{
                            setState(() {
                              isUserNameEmpty = true;
                            });

                      }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.black,
                    ),
                    labelText: "username",
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                            color:Colors.indigo
                        )
                    ),
                  ),
                  keyboardType: TextInputType.text
              ),
              if(isUserNameEmpty)
                Text("please fillup username",style: TextStyle(color:Colors.black),)
              else if(!isUniqueUserName )
                Text("not unique",style: TextStyle(color:Colors.redAccent),)
              else if(isUniqueUserName) Text("unique",style: TextStyle(color:Colors.teal),)
              ,

              SizedBox(height: 20),
              TextField(
                  controller:_passwordTextController,
                  obscureText:!isPasswordVisible,
                  enableSuggestions:false,
                  autocorrect:false,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black.withOpacity(0.9)),
                  onChanged:(value){
                    setState(() {
                      if(value.trim().isEmpty){
                        isPasswordEmpty=true;
                      }
                      else{
                        isPasswordEmpty=false;
                      }
                      if(value.trim().length<6){
                        isPasswordValid=false;
                      }
                      else{
                        isPasswordValid=true;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                    labelText: "password",
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                            color:Colors.indigo
                        )
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword
              ),
              if(isPasswordEmpty)
                Text("please fillup password",style: TextStyle(color:Colors.black),)
              else if(!isPasswordValid )
                Text("password atleast 6 characters",style: TextStyle(color:Colors.redAccent),)
              ,

              SizedBox(height: 20),
              TextField(
                  controller:_birthdateTextController,
                  obscureText:false,
                  enableSuggestions:true,
                  autocorrect:true,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black.withOpacity(0.9)),
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
                      color: Colors.black,
                    ),
                    labelText: "birthdate",
                    labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                            color:Colors.indigo
                        )
                    ),
                  ),
                  keyboardType: TextInputType.datetime
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isUpdating?null:updateProfile,
                child:isUpdating?CircularProgressIndicator():Text("Update Profile"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
