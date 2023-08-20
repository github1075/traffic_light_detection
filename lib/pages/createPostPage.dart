import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:traffic_light_detection/pages/dashboardPage.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool isPostEnable=false;
  String userName = "your name";
  String profilePictureUrl = 'https://i.stack.imgur.com/l60Hf.png';
  User? user = FirebaseAuth.instance.currentUser;
  DateTime? now;
  String formattedDate = "";
  File? _imageFile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _textEditingController = TextEditingController();

  // current date  and time
  String getDate() {
    now = DateTime.now();
    formattedDate = DateFormat('MMMM d \'at\' h:mma').format(now!);
    return formattedDate;
  }

  // user profile pic and username
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("UsersInformation")
        .doc(user?.email)
        .get()
        .then((value) {
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
      'profilePicture': profilePictureUrl,
      'userName': userName,
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashboardPage()));
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        _imageFile = File(image.path);
        enablePostButton();
      }
    });
  }
  void enablePostButton(){

    if((_imageFile!=null)||(_textEditingController.text.trim().isNotEmpty && _textEditingController.text.trim()!="")){
      print("yes");
      setState(() {
        isPostEnable=true;
      });
    }
    else{
      setState(() {
        isPostEnable=false;
      });
    }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => DashboardPage()));
          },
        ),
        title: const Text(
          'Create Post',
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureUrl),
                      radius: 70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "$userName",
                      style: TextStyle(
                          color: Colors.indigo[500],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      getDate(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _textEditingController,
                    onChanged:(value){
                      enablePostButton();
                    },
                    decoration: InputDecoration(
                        hintText: "Write a caption...",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.indigo.shade300
                          )
                        )),
                    maxLines: 8,
                  ),
                ],
              ),
              Divider(),
              _imageFile != null
                  ? Column(
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : SizedBox(height: 20),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                    label: const Text('Picture'),
                    onPressed: _selectImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.post_add,
                      color: Colors.white,
                    ),
                    label: const Text('Post'),
                    onPressed: isPostEnable ? _uploadStatus: null ,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
