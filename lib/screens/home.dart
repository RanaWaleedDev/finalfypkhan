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
import 'package:campus_navigation/screens/view_story.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:campus_navigation/models/my_user.dart';
import 'package:campus_navigation/models/news.dart';
import 'package:campus_navigation/screens/auth/login_page.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Footer.dart';
import '../models/story.dart';

class HomeScreen extends StatefulWidget {
  final MyUser newUser;

  const HomeScreen(this.newUser, {Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final databaseRef = FirebaseDatabase.instance.ref();
  late DatabaseReference _newsRef;
  late DatabaseReference _storiesRef;
  late List<Story> _storiesList;
  late List<News> _newsList;
  late List<String> _uniqueCategoryList;
  var currentScreenIndex = 0;

  @override
  void initState() {
    super.initState();
    _newsRef = databaseRef.child('news');
    _storiesRef = databaseRef.child('stories');
    _storiesList = [];
    _newsList = [];
    _uniqueCategoryList = [];
    // Make Stories List Data
    _storiesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        DateTime now = DateTime.now();
        int dayInMilliseconds = 24 * 60 * 60 * 1000;
        map?.forEach((key, value) {
          String id = value['id'];
          String channelName = value['channelName'];
          String channelLogoUrl = value['channelLogoUrl'];
          String storyPhotoUrl = value['storyPhotoUrl'];
          int date = value['date'];
          DateTime storyDateTime = DateTime.fromMillisecondsSinceEpoch(date);
          if (now.difference(storyDateTime).inMilliseconds <=
              dayInMilliseconds) {
            Story story = Story(
                id: id,
                channelName: channelName,
                channelLogoUrl: channelLogoUrl,
                storyPhotoUrl: storyPhotoUrl,
                date: date);
            setState(() {
              _storiesList.add(story);
            });
          }
        });
      }
    });

    // Make news List Data
    _newsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        map?.forEach((key, value) {
          if (!_uniqueCategoryList.contains(value["category"])) {
            _uniqueCategoryList.add(value["category"]);
          }
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

  Future<void> insertStory() async {
    String? _story_key = await _storiesRef.push().key;
    Story news = Story(
        id: _story_key,
        storyPhotoUrl:
            "channels/espn/stories/cricketteam.webp",
        channelLogoUrl: "channels/tr/logo.jpg",
        channelName: "Talha",
        date: DateTime.now().millisecondsSinceEpoch);
    print("story key: ${_story_key}");
    print(news.id);
    _storiesRef.child(_story_key!).set(news.toJson());
  }

  @override
  Widget build(BuildContext context) {
    // insertStory();
    if (widget.newUser.uid == null) {
      return const LoginPage();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          
          const Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              "Stories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              scrollDirection: Axis.horizontal,
              itemCount: _storiesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ViewStory(story: _storiesList[index])));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                                width: 2, color: const Color(0xFFB92B27)),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB92B27), Color(0xFF1565C0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(150),
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 3,
                                left: 3,
                                child: CircleAvatar(
                                  radius: 34,
                                  backgroundImage: AssetImage(
                                    _storiesList[index].channelLogoUrl!,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _storiesList[index].channelName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(
            thickness: 1,
          ),
          SizedBox(
            height: 550,
            
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _uniqueCategoryList.length,
                itemBuilder: (context, cat_index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _uniqueCategoryList[cat_index],
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _newsList.length,
                            itemBuilder: (context, newsIndex) {
                              if (_uniqueCategoryList[cat_index] !=
                                  _newsList[newsIndex].category) {
                                return const SizedBox(
                                  width: 5,
                                ); // Skip if category does not match
                              } else {
                                DateTime timestamp = DateTime
                                    .fromMillisecondsSinceEpoch(_newsList[
                                            newsIndex]
                                        .date!); // replace with your timestamp
                                DateTime now = DateTime.now();
                                int hoursAgo =
                                    now.difference(timestamp).inHours;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ViewNews(
                                                news: _newsList[newsIndex],
                                              )),
                                    );
                                  },
                                  child: Card(
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          _newsList[newsIndex].photoUrl!,
                                          height: 150,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          _newsList[newsIndex]
                                              .title!
                                              .substring(0, 25),
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          '$hoursAgo hours ago',
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                      )
                    ],
                  );
                }),
          ),
          AboutFooter()
        ],
      ),
    );
  }
}
