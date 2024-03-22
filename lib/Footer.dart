import 'package:flutter/material.dart';

class AboutFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: Colors.grey[900],
      child: Column(
        children: [
          Text(
            'About Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(
              'Our fake news detection app uses advanced machine learning algorithms to analyze news articles and identify fake or misleading content. With a user-friendly interface, users can quickly check the credibility of news articles before sharing them on social media or relying on them for important decisions. Our app aims to combat the spread of fake news and promote trustworthy journalism.',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Follow Us',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.facebook),
                color: Colors.white,
                onPressed: () => {},
              ),
              IconButton(
                icon: Icon(Icons.tab),
                color: Colors.white,
                onPressed: () => {},
              ),
              IconButton(
                icon: Icon(Icons.insert_page_break),
                color: Colors.white,
                onPressed: () => {},
              ),
              IconButton(
                icon: Icon(Icons.youtube_searched_for_sharp),
                color: Colors.white,
                onPressed: () => {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
