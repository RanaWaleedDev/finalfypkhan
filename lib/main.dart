import 'package:campus_navigation/models/my_user.dart';
import 'package:campus_navigation/screens/auth/login_page.dart';
import 'package:campus_navigation/screens/auth/splashscreen.dart';
import 'package:campus_navigation/screens/home.dart';
import 'package:campus_navigation/screens/imageProcess.dart';
import 'package:campus_navigation/screens/search_news_text.dart';
import 'package:campus_navigation/screens/settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// To run app: flutter run -d chrome --web-renderer html --no-sound-null-safety
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDitDGg5TfAUsUmLewUIdPbjLGlV9oiRsk",
            appId: "1:230712877530:web:a788d7e3c6083677a920e3",
            messagingSenderId: "230712877530",
            projectId: "campus-navigation-2f274",
            databaseURL:
                'https://campus-navigation-2f274-default-rtdb.firebaseio.com/', // Your Firebase URL
            storageBucket: "gs://campus-navigation-2f274.appspot.com"));
  } else {
    await Firebase.initializeApp();
  }
  if (kDebugMode) {
    print('Firebase connected');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fake News Detection',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: 
        // const MyScreens()
        const Splash()
        );
  }
}

class MyScreens extends StatefulWidget {
  const MyScreens({super.key});

  @override
  State<MyScreens> createState() => _MyScreensState();
}

class _MyScreensState extends State<MyScreens> {
  var currentScreenIndex = 0;
  MyUser myUser = MyUser(
      uid: "-NSVD4BhwBBFT3ukSG1D",
      email: "talha@user.com",
      password: "12345678",
      photoUrl:
          "users/my.jpg");

  late List<Widget> _children;

  @override
  Widget build(BuildContext context) {
    _children = [
      HomeScreen(myUser),
      const TextSearchNews(),
      ImageProcessScreen(myUser)
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Fake News Dectection",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingScreen(myUser),
                      ));
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                )),
          )
        ],
      ),
      body: _children[currentScreenIndex],
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          currentIndex: currentScreenIndex,
          onTap: (index) {
            setState(() {
              currentScreenIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
              backgroundColor: Colors.blueAccent,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Agent",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.image), label: "Vision")
          ]),
    );
  }
}
