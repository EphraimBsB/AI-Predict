import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

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
  late Interpreter interpreter;
  bool result = false;
  double? prediction;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
        result = false;
      });
    } on PlatformException catch (e) {
      print('Faild to pick image $e');
    }
  }

  predictImage() async {
    var imageBytes = await image!.readAsBytes();
    var decodedImage = img.decodeImage(imageBytes);
    var resizedImage = img.copyResize(decodedImage!, height: 256, width: 256);
    double probability;
    List input = List.generate(
            1 * 256 * 256 * 3, (i) => resizedImage.getBytes()[i] / 255.0)
        .reshape([1, 256, 256, 3]);
    var output = List.filled(1 * 1, 0).reshape([1, 1]);

    // input = input.reshape([1, 224, 224, 3]); // Reshape the input tensor
    // print("INPUT RESHAPE===> $input");
    interpreter.run(input, output);
    print("OUTPUT===> ${output.first}");
    probability = output[0][0];
    double prob = probability * 100;
    setState(() {
      prediction = double.parse(prob.toStringAsFixed(2));
    });
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
                ? Column(
                    children: [
                      const Text(
                        'Cassava Stem Scanner',
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(
                            image!,
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/image.png'),
                        radius: 50,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Cassava Stem Scanner',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Results:',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Health: ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextSpan(
                            text: prediction! < 50 ? 'Healthy' : 'Unhealthy',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Probability: ',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          TextSpan(
                            text: prediction! < 50
                                ? '${100 - prediction!} %'
                                : '$prediction %',
                            style: const TextStyle(
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
              height: 30.0,
            ),
            InkWell(
              onTap: image != null
                  ? () async {
                      await predictImage();
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
