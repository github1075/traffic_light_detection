import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {

  List? _outputs;
  File? _image;
  bool _loading = false;
  final imgPicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite",
      numThreads: 1,
    );
  }

  classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
        path: image!.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output;
      print("output\n");
      print(_outputs);
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  void pickimage() async {
    var imgGallery = await imgPicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = File(imgGallery!.path);
    });
    classifyImage(_image);
  }

  void pickImageGallery() async {
    var imgGallery = await imgPicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(imgGallery!.path);
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white12,
        title: Text(
          'Traffic Light Detection App',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
      body: Container(
        color: Colors.grey,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _loading
                  ? Container(
                height: MediaQuery.of(context).size.height * .9,
                child: Center(
                  child: Text(
                    'Select an image...',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              )
                  : Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  height: MediaQuery.of(context).size.height * .76,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _image == null
                          ? Container()
                          : Card(
                        elevation: 45,
                        child: Image.file(_image!,
                            fit: BoxFit.cover,
                            height:
                            MediaQuery.of(context).size.height *
                                .6),
                      ),
                      SizedBox(height: 10),
                      _image == null
                          ? Container(
                        child: Text(
                          'No image selected',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      )
                          : _outputs != null
                          ? Card(
                        color: Colors.green,
                        margin: EdgeInsets.all(8),
                        elevation: 10,
                        child: SizedBox(
                          width: MediaQuery.of(context)
                              .size
                              .width *
                              .8,
                          child: Text(
                            _outputs![0]["label"].substring(
                              1,
                            ),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          : Container()
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(

                onPressed: () {
                  pickimage();
                },
                icon: Icon(
                  // <-- Icon
                  Icons.photo_camera,
                  size: 30,
                ),
                label: Text('Camera'), // <-- Text
              ),
              ElevatedButton.icon(
                onPressed: () {
                  pickImageGallery();
                },
                icon: Icon(
                  // <-- Icon
                  Icons.photo,
                  size: 30,
                ),
                label: Text('Gallery'), // <-- Text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
