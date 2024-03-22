import 'dart:convert';

import 'package:campus_navigation/screens/view_news.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;

import '../models/news.dart';

// e.g to search
// How much videos about cosmetic surgery
// Will Whatsapp release new feature?
// did lahore court give reliel to imran khan?
// Will Pakistan again go to IMF







class TextSearchNews extends StatefulWidget {
  const TextSearchNews({super.key});

  @override
  State<TextSearchNews> createState() => _TextSearchNewsState();
}

class _TextSearchNewsState extends State<TextSearchNews> {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  final databaseRef = FirebaseDatabase.instance.ref();
  late DatabaseReference _newsRef;
  late List<News> _newsList;
  late List<dynamic> _resultNewsList;
  String _userQuery = "";
  var isSendPressed = false;
  @override
  void initState() {
    super.initState();
    _newsList = [];
    _resultNewsList = [];

    _newsRef = databaseRef.child('news');
// Make news List Data
    _newsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        map?.forEach((key, value) {
          News news = News(
              id: value["id"],
              title: value["title"],
              description: value["description"],
              photoUrl: value["photoUrl"],
              category: value["category"],
              date: value["date"]);
          setState(() {
            _newsList.add(news);
          });
        });
      }
    });
  }

  void sendData(String userQuery, List<News> newsList) {
    Map<String, dynamic> data = {"userQuery": userQuery, 'newsList': newsList};
    String jsonData = jsonEncode(data);
    http
        .post(Uri.parse("http://localhost:5000/lang/process"),
            headers: headers, body: jsonData)
        .then((response) {
      if (response.statusCode == 200) {
        // request successful, handle response
        setState(() {
          _resultNewsList = jsonDecode(response.body)["newsList"];
          isSendPressed = false;
        });
      } else {
        // request failed, handle error
        print('Request failed with status: ${response.statusCode}.');
      }
    }).catchError((error) {
      // error occurred while making request
      print('Error sending request: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        bottom: 10,
        left: MediaQuery.of(context).size.width / 5,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Icon(Icons.search),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _userQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Ask Something?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        isSendPressed = true;
                      });
                      sendData(_userQuery, _newsList);
                    },
                    icon: const Icon(Icons.send_rounded))
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
                  children:  [
                     const Align(
                      alignment: Alignment.centerLeft,
                      child:  Padding(
                        padding:  EdgeInsets.all(16),
                        child: Text("Belongings", style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                      ),
                    ),
                    if (isSendPressed == true) const CircularProgressIndicator(color: Colors.blue,)
                  ],
                ),
                _resultNewsList.length > 0 ?
                Expanded(
                  child: ListView.builder(
                      itemCount: _resultNewsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewNews(
                                        news: News.fromMap(_resultNewsList[index]),
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 300,
                                        child: Text(
                                          _resultNewsList[index]["answer"],
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
                ): Center(child: Text("No Item to Display"),),
              ],
            )
            
      ),
    ]);
  }
}
