import 'dart:async';
// import 'dart:html';
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:convert';
import 'package:campus_navigation/screens/view_news.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:campus_navigation/models/my_user.dart';
import 'package:campus_navigation/models/news.dart';
import 'package:campus_navigation/screens/auth/login_page.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:image/image.dart' as img;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Cosine similarity works better on images that have similar features or patterns, such as images of the same object taken from different angles or images with similar color schemes.
double cosineSimilarity(List<double> v1, List<double> v2) {
  double dotProduct = 0.0;
  double magV1 = 0.0;
  double magV2 = 0.0;
  for (int i = 0; i < v1.length; i++) {
    dotProduct += v1[i] * v2[i];
    magV1 += v1[i] * v1[i];
    magV2 += v2[i] * v2[i];
  }
  magV1 = math.sqrt(magV1);
  magV2 = math.sqrt(magV2);
  return dotProduct / (magV1 * magV2);
}

double ssimSimilarity(List<double> x, List<double> y) {
  // Compute mean and variance of x and y
  double meanX = x.reduce((a, b) => a + b) / x.length;
  double meanY = y.reduce((a, b) => a + b) / y.length;
  double varX =
      x.map((e) => math.pow(e - meanX, 2)).reduce((a, b) => a + b) / x.length;
  double varY =
      y.map((e) => math.pow(e - meanY, 2)).reduce((a, b) => a + b) / y.length;
  double covXY = x
          .asMap()
          .map((i, e) => MapEntry(i, e * y[i]))
          .values
          .reduce((a, b) => a + b) /
      x.length;

  // Set constants
  num c1 = math.pow(0.01 * 255, 2);
  num c2 = math.pow(0.03 * 255, 2);

  // Compute SSIM components
  double luminance =
      (2 * meanX * meanY + c1) / (math.pow(meanX, 2) + math.pow(meanY, 2) + c1);
  double contrast =
      (2 * math.sqrt(varX) * math.sqrt(varY) + c2) / (varX + varY + c2);
  double structure =
      (covXY + c2 / 2) / (math.sqrt(varX) * math.sqrt(varY) + c2 / 2);

  // Compute SSIM score
  return luminance * contrast * structure;
}

void bytesComparsion(Uint8List imageBytes1, Uint8List imageBytes2) {
  final image1 = img.decodeImage(imageBytes1);
  final image2 = img.decodeImage(imageBytes2);
  // Resize the images to the same size
  final width = math.min(image1!.width, image2!.width);
  final height = math.min(image1.height, image2.height);
  final resizedImage1 = img.copyResize(image1, width: width, height: height);
  final resizedImage2 = img.copyResize(image2, width: width, height: height);
  // Convert images to lists of pixel values
  final pixels1 = resizedImage1.data.toList();
  final pixels2 = resizedImage2.data.toList();
  // Convert list values to Double
  final pixels1Double = pixels1.map((p) => p.toDouble()).toList();
  final pixels2Double = pixels2.map((p) => p.toDouble()).toList();
  // Calculate cosine similarity
  final similarity = cosineSimilarity(pixels1Double, pixels2Double);
  final ssim = ssimSimilarity(pixels1Double, pixels2Double);
  if (kDebugMode) {
    print("cosine similarity: $similarity");
    print("ssim similarity: $ssim");
  }
}



Future<Uint8List> getImageBytesFromAsset(String assetPath) async {
  final ByteData data = await rootBundle.load(assetPath);
  return data.buffer.asUint8List();
}

Future<Uint8List?> _getSelectedFile() async {
  final completer = Completer<Uint8List?>();
  final input = html.FileUploadInputElement();
  input.accept = 'image/*';
  input.click();
  input.onChange.listen((event) {
    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) {
      final bytes = reader.result as Uint8List;
      completer.complete(bytes);
    });
  });
  return completer.future;
}

class ImageProcessScreen extends StatefulWidget {
  final MyUser newUser;

  const ImageProcessScreen(this.newUser, {Key? key}) : super(key: key);

  @override
  State<ImageProcessScreen> createState() => _ImageProcessScreenState();
}

class _ImageProcessScreenState extends State<ImageProcessScreen> {
  final databaseRef = FirebaseDatabase.instance.ref();
  late DatabaseReference _newsRef;
  late List<News> _newsList;
  Map<String, String> headers = {'Content-Type': 'application/json'};
  late List<dynamic> _resultNewsList;
  Uint8List? selectedFile;
  var isSendPressed = false;
  Future<void> sendData(
    Uint8List uint8List1,
  ) async {
    var url = Uri.parse('http://localhost:5000/img/process');
    var request = http.MultipartRequest('POST', url);

    request.files.add(
      http.MultipartFile.fromBytes('usr_image', uint8List1,
          filename: 'image1.jpg'),
    );

    request.fields["newsList"] = jsonEncode(_newsList);

    var response = await request.send();
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(await response.stream.bytesToString());
      // Do something with the response JSON, if needed
      setState(() {
        _resultNewsList = responseJson["newsList"];
        isSendPressed = false;
      });
      print('Got Response');
    } else {
      print('Error uploading image: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _newsRef = databaseRef.child('news');
    _newsList = [];
    _resultNewsList = [];

    _newsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        map?.forEach((key, value) {
          String id = value['id'];
          String title = value['title'];
          String description = value['description'];
          String photoUrl = value['photoUrl'];
          String category = value['category'];
          int date = value['date'];
          News news = News(
              id: id,
              title: title,
              description: description,
              photoUrl: photoUrl,
              category: category,
              date: date);
          setState(() {
            _newsList.add(news);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // insertNews();
    if (widget.newUser.uid == null) {
      return const LoginPage();
    }

    return Stack(children: [
      Positioned(
        bottom: 10,
        left: MediaQuery.of(context).size.width / 5,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Icon(Icons.image),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        child: Text(
                          selectedFile == null
                              ? "Select Image"
                              : "File is Selected",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        onPressed: () {
                          setState(() {
                            _getSelectedFile().then((value) {
                              setState(() {
                                selectedFile = value;
                              });
                            });
                          });
                        },
                      )),
                )),
                Visibility(
                  visible: selectedFile != null,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isSendPressed = true;
                        });
                        sendData(selectedFile!);
                      },
                      icon: const Icon(Icons.send_rounded)),
                )
              ],
            ),
          ),
        ),
      ),
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 60,
          child: Column(
            children: [
              Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Belongings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ),
                  ),
                  if(isSendPressed) const CircularProgressIndicator(color: Colors.blue,)
                ],
              ),
              _resultNewsList.length > 0
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _resultNewsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewNews(
                                          news: News.fromMap(
                                              _resultNewsList[index]),
                                        )),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage(
                                        _resultNewsList[index]["photoUrl"],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 40,
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 300,
                                          child: Text(
                                            _resultNewsList[index]["title"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Text("No Item to Display"),
                    ),
            ],
          )),
    ]);
  }
}
