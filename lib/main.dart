// ignore_for_file: unused_local_variable, use_key_in_widget_constructors, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'dart:developer' as devtools;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AZMAMKS_FER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1, 
      isAsset: true, 
      useGpuDelegate: false,
    );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path, 
      imageMean: 0.0, 
      imageStd: 255.0, 
      numResults: 2, 
      threshold: 0.2, 
      asynch: true, 
    );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
      path: image.path, 
      imageMean: 0.0, 
      imageStd: 255.0, 
      numResults: 2, 
      threshold: 0.2, 
      asynch: true, 
    );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Face Emotion Recognition"),
      // ),
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/Mobile-pictur1e.jpg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Card(
                    elevation: 20,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 18,
                            ),
                            Container(
                              height: 280,
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: AssetImage('assets/upload.jpg'),
                                ),
                              ),
                              child: filePath == null
                                  ? const Text('')
                                  : Image.file(
                                      filePath!,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Simple Speed Dial
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('Speed Dial is Opened'),
        onClose: () => print('Speed Dial is Closed'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Color.fromARGB(255, 0, 167, 157),
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt),
            backgroundColor: Color.fromRGBO(0, 167, 157, 1),
            foregroundColor: Colors.white,
            label: 'Take a Photo',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: pickImageCamera,
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_library),
            backgroundColor: Color(0xFF00A79D),
            foregroundColor: Colors.white,
            label: 'Pick from Gallery',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: pickImageGallery,
          ),
        ],
      ),
    );
  }
}
