import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MaterialApp(
    home: DetectionPage(),
  ));
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  List<dynamic>? _outputs;
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

  Future<void> loadModel() async {
    await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite",
      numThreads: 1,
    );
  }

  Future<void> classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
      path: image!.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2, // Change to 3 since you have three classes
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  void pickImage() async {
    var imgGallery = await imgPicker.pickImage(source: ImageSource.camera);
    if (imgGallery != null) {
      setState(() {
        _image = File(imgGallery.path);
        _outputs = null; // Clear the previous outputs
      });
      classifyImage(_image);
    }
  }

  void pickImageGallery() async {
    var imgGallery = await imgPicker.pickImage(source: ImageSource.gallery);
    if (imgGallery != null) {
      setState(() {
        _image = File(imgGallery.path);
        _outputs = null; // Clear the previous outputs
      });
      classifyImage(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo[400],
        title: Text("Pedict Traffic Light",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height:25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(
                      Icons.photo_camera,
                      size: 30,
                    ),
                    label: Text('Take a Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: pickImageGallery,
                    icon: Icon(
                      Icons.photo,
                      size: 30,
                    ),
                    label: Text('Choose from Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_loading)
                CircularProgressIndicator()
              else if (_image == null)
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Text(
                      'No image selected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              else if (_outputs == null)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        'Perform prediction to see results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    color: Colors.indigo[200],
                    margin: EdgeInsets.all(8),
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height * 0.4,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Detected Labels:',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 5),
                          for (var output in _outputs!)
                            Text(
                              '${output["label"].substring(1)}: ${((output["confidence"] as double) * 100).toStringAsFixed(2)}%'.toUpperCase(),
                              style: TextStyle(
                                fontSize:23,
                                color: Colors.teal,
                                fontWeight: FontWeight.bold
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
    );
  }
}
