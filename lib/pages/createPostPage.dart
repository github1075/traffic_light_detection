import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String userName=" your name";
  String  profilePictureUrl='https://i.stack.imgur.com/l60Hf.png';
  User? user=FirebaseAuth.instance.currentUser;
  DateTime? now;
  String formattedDate="";
  File? _imageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _textEditingController = TextEditingController();
// current date  and time
  String getDate() {
    now = DateTime.now();
    setState(() {
      formattedDate= DateFormat('MMMM d \'at\' h:mma').format(now!);

    });
    return formattedDate;

  }

// user profile pic and username
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection("UsersInformation").doc(user?.email).get().then((value) {
      setState(() {
        userName = value.data()?["userName"];
        profilePictureUrl = value.data()?["profilePicture"];

      });
    });
  }
  // upload the post
  Future<void> _uploadStatus() async {
    String? imageUrl;

    // Upload the image to Firebase Storage if available
    if (_imageFile != null) {
      final String imagePath = 'images/${DateTime.now().toString()}.png';
      final Reference storageRef = _storage.ref().child(imagePath);
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      final TaskSnapshot taskSnapshot = await uploadTask;
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var user = _auth.currentUser;

    // Add the status to Firestore
    await _firestore.collection('statuses').add({
      'postBy': user!.email,
      'profilePicture':profilePictureUrl,
      'userName':userName,
      'text': _textEditingController.text,
      'image': imageUrl,
      'timestamp': DateTime.now(),
      'likes': 0,
      'comments': 0,
      "likeBy": [],
    });

    // Clear the input fields
    _textEditingController.clear();
    setState(() {
      _imageFile = null;
    });
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>DashboardPage()));
  }
  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:() {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardPage()));

          },
        ),
        title: const Text(
          'Create Post',
        ),
        centerTitle: false,
      ),
      // POST FORM
      body: Column(
        children:[
          Padding(padding: EdgeInsets.only(top: 0.0)),
          const Divider(),
              Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePictureUrl),
                    radius: 70,
                  ),
                  SizedBox(height:5,),
                  Text("$userName",style:TextStyle(color:Colors.blue,fontSize:25,fontWeight: FontWeight.bold),),
                  SizedBox(height:5,),
                  Text(getDate(),style:TextStyle(color:Colors.black,fontSize:20,fontWeight: FontWeight.normal),),
                  SizedBox(height:10,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                          hintText: "Write a caption...",
                          border: InputBorder.none),
                      maxLines: 8,
                    ),
                  ),

                ],
              ),
          Divider(),
          _imageFile != null?
          SizedBox(
            height: 200,
            child: Image.file(
              _imageFile!,
              height: 200,
              fit: BoxFit.cover,
            ),
          )
          :SizedBox(height: 20,),
          Row(
            mainAxisAlignment:MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              ElevatedButton.icon (
                icon: const Icon (
                  Icons.image,
                  color: Colors.white,
                  size:30,
                ),
                label: const Text ('Picture',style: TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold),),
                onPressed:_selectImage,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 50),
                  backgroundColor: Colors.green[400]
                ),
              ),
              ElevatedButton.icon (
                icon: const Icon (
                  Icons.control_point_sharp,
                  color: Colors.white,
                  size: 30,
                ),
                label: const Text ('Post',style: TextStyle(color: Colors.white,fontSize:15,fontWeight: FontWeight.bold),),
                onPressed:_uploadStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor:Colors.indigo,
                  fixedSize: Size(200, 50),
                ),
              )

            ],

          )
        ],
      ),
    );
  }
}
