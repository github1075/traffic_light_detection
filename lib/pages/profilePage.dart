import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Uint8List? _image,im;
  bool isSelectImage=false;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
          ],
        ),
      ),
    );
  }
}

