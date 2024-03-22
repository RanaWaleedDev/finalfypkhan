import 'dart:async';
import 'package:campus_navigation/models/story.dart';
import 'package:flutter/material.dart';

class ViewStory extends StatefulWidget {
  final Story story;

  const ViewStory({super.key, required this.story});

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  late Timer _timer;
  double _sliderValue = 5;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_sliderValue > 0) {
          _sliderValue--;
        } else {
          _timer.cancel();
          Navigator.of(context).pop();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            widget.story.storyPhotoUrl!,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                _timer.cancel();
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SliderTheme(
                data: SliderThemeData(
                  thumbShape: SliderComponentShape.noThumb,
                  disabledActiveTrackColor: Colors.white
                ),
                child: Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  onChanged: null,
                ),
              )),
        ],
      ),
    );
  }
}
