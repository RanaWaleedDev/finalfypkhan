import 'package:campus_navigation/models/news.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ViewNews extends StatefulWidget {
  final News news;
  const ViewNews({required this.news, super.key});

  @override
  State<ViewNews> createState() => _ViewNewsState();
}

class _ViewNewsState extends State<ViewNews> {
  final databaseReference = FirebaseDatabase.instance.ref();
  late DatabaseReference _newsRef;

  List<News> _relatedNewsList = [];

  @override
  void initState() {
    super.initState();
    _newsRef = databaseReference.child('news');

    // Make news List Data
    _newsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map?;
        map?.forEach((key, value) {
          if (value['category'] == widget.news.category &&
              value["id"] != widget.news.id) {
            News news = News(
                id: value["id"],
                title: value["title"],
                description: value["description"],
                photoUrl: value["photoUrl"],
                category: value["category"],
                date: value["date"]);
            setState(() {
              _relatedNewsList.add(news);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime newsDateTime =
        DateTime.fromMillisecondsSinceEpoch(widget.news.date!);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.blue, fontSize: 17),
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.news.title!,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                  "${newsDateTime.day} - ${newsDateTime.month} - ${newsDateTime.year}"),
              const SizedBox(
                height: 20,
              ),
              Image.asset(widget.news.photoUrl!),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(widget.news.description!),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Related",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )),
              ),
              SizedBox(
                height: 200,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  children: List.generate(_relatedNewsList.length, (newsIndex) {
                    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
                        _relatedNewsList[newsIndex]
                            .date!); 
                    DateTime now = DateTime.now();
                    int hoursAgo = now.difference(timestamp).inHours;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewNews(
                                    news: _relatedNewsList[newsIndex])));
                      },
                      child: Card(
                        child: Column(
                          children: [
                            Image.asset(
                              _relatedNewsList[newsIndex].photoUrl!,
                              height: 150,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              _relatedNewsList[newsIndex].title!,
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
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
