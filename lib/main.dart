import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AI Predict',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? image;

  bool result = false;

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print('Faild to pick image $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image != null
                ? Image.file(
                    image!,
                    height: 220,
                    width: double.infinity,
                  )
                : const Column(
                    children: [
                      Text(
                        'AI Image Predict',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30.0),
                        child: Text(
                          'Know the health of your cassava with AI image prediction. Take or upload an image of your cassava to see if its healthy or not',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
            //
            if (result)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Health: ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextSpan(
                            text: 'Healthy',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Accuracy: ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextSpan(
                            text: '99.9%',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            //
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => pickImage(ImageSource.gallery),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        'Pick Gallery',
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 50.0,
                ),
                InkWell(
                  onTap: () => pickImage(ImageSource.camera),
                  child: const Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text('Pick Camera', style: TextStyle(fontSize: 12))
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40.0,
            ),
            InkWell(
              onTap: image != null
                  ? () {
                      setState(() {
                        result = !result;
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
                decoration: BoxDecoration(
                    color: image != null ? Colors.green : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0)),
                child: Text(
                  'Predict',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: image != null
                          ? Colors.white
                          : Colors.black.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
