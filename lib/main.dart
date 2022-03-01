import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MaterialApp(
      home: HomeScreen(),
    )); //MaterialApp

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _result = [];
  String numbers = '';

  String _confidence = "";
  String _name = "";
  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      this.image = imageTemporary;
      setState(() {
        this.image = imageTemporary;
        applyModelOnImage(imageTemporary);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  loadModel() async {
    var resultant = await Tflite.loadModel(
        labels: "assets/Marvel.txt", model: "assets/marveltesting.tflite");

    print("Result after loading model: $resultant");
  }

  applyModelOnImage(File file) async {
    dynamic res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _result = res;
      print(_result);

      String str = _result[0]['label'];

      _name = str.substring(0);
      _confidence = _result != null
          ? (_result[0]['confidence'] * 100.0).toString().substring(0, 2) + "%"
          : "";
    });
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Marvel Classifier"),
      ),

      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            image != null
                ? Image.file(
                    image!,
                    width: 350,
                    height: 350,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(
                    width: 350,
                    height: 350,
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.amber)),
                  ),
            Positioned(
                right: -10,
                top: -20,
                child: IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.black.withOpacity(0.5),
                      size: 18,
                    ),
                    onPressed: () => setState(() {
                          image = null;
                        }))),

            // : Text(
            //     'Image Picker',
            //     style: TextStyle(
            //       fontSize: 48,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            SizedBox(height: 30),
            Text(
              'Name : $_name \nConfidence: $_confidence',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ), //container
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImage();
        },
        child: Icon(Icons.photo_album),
      ), //floatingactionbutton
    ); //Scaffold
  }
}
