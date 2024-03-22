import 'package:campus_navigation/models/my_user.dart';
import 'package:campus_navigation/screens/auth/signup_page.dart';
import 'package:campus_navigation/screens/home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getUserLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('uid');
}

Future<MyUser?> getUserById(BuildContext context, String id) async {
  try {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(id);

    DataSnapshot snapshot = (await userRef.once()).snapshot;

    if (snapshot.value == null) {
      return null;
    }
    MyUser myUser = MyUser.fromMap(snapshot.value as Map<dynamic, dynamic>);
    return myUser;
  } catch (e) {
    if (kDebugMode) {
      print('Error getting user by ID: $e');
    }
  }
  return null;
}

final databaseReference = FirebaseDatabase.instance.ref();

Future<Map> _loginUser(String email, String password) async {

  try {
    // Check if user with the given email exists
    DataSnapshot snapshot = (await databaseReference
            .child('users')
            .orderByChild('email')
            .equalTo(email)
            .once())
        .snapshot;
        
    if (snapshot.value == null) {
      // User doesn't exist
      return {"status": 404, "msg": 'User not found'};
    }
    Map values = snapshot.value as Map<dynamic, dynamic>;

    Map<String, dynamic> myUser = {
      "uid": values[values.keys.first]["uid"],
      "email": values[values.keys.first]["email"],
      "password": values[values.keys.first]["password"],
      "photoUrl": values[values.keys.first]["photoUrl"],
    };

    if (myUser['password'] != password) {
      // Password doesn't match
      return {"status": 400, "msg": 'Incorrect password'};
    }
    
    return {"status": 200, "msg": "User LoggedIn!", "user": myUser};

  } catch (error) {
    // Return error message
    return {"status": 500, "msg": 'Error logging in'};
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _emailInputError = "", _passwordInputError = "";
  final double _columnItemDistance = 20;
  String _emailInput = "", _passwordInput = "";
  bool _showPassword = false;

  // Database
  @override
  void initState() {
    super.initState();
    getUserLoggedIn().then((userId) {
      userId ??= "null";
      getUserById(context, userId).then((foundUser) {
        print("FOund USer: ${foundUser}");
        if (foundUser?.uid != null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(foundUser!)));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login to your account",
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.bold,
                    fontSize: 35),
              ),
              // Email Input ----------------------------------------------------------
              SizedBox(
                height: _columnItemDistance,
              ),
              const Text(
                "Email",
                style: TextStyle(
                    fontFamily: "Roboto", fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(
                    color: _emailInputError != ""
                        ? Colors.red
                        : const Color.fromARGB(255, 183, 238, 255),
                    width: 2.0,
                  ),
                ),
                child: TextFormField(
                  cursorColor: Colors.black,
                  onChanged: ((value) {
                    setState(() {
                      _emailInput = value;
                      _emailInputError = "";
                    });
                  }),
                  decoration: const InputDecoration(
                    hintText: "Enter Email",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Visibility(
                    visible: _emailInputError != "" ? true : false,
                    child: Text(
                      _emailInputError,
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    )),
              ),
              // Password Input ----------------------------------------------------------
              SizedBox(
                height: _columnItemDistance,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Password",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 18,
                        color: Colors.blueGrey),
                  ),
                  Text(
                    "Forget Password",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 15,
                        color: Color.fromARGB(255, 0, 170, 255)),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  border: Border.all(
                    color: _passwordInputError != ""
                        ? Colors.red
                        : const Color.fromARGB(255, 183, 238, 255),
                    width: 2.0,
                  ),
                ),
                child: TextFormField(
                  cursorColor: Colors.black,
                  obscureText: !_showPassword,
                  onChanged: ((value) {
                    setState(() {
                      _passwordInput = value;
                      _passwordInputError = "";
                    });
                  }),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                    hintText: "Enter Password",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Visibility(
                    visible: _passwordInputError != "" ? true : false,
                    child: Text(
                      _passwordInputError,
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    )),
              ),
              SizedBox(
                height: _columnItemDistance,
              ),
              // Login Button ----------------------------------------------------------
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    _loginUser(_emailInput, _passwordInput)
                        .then((result) async {
                      if (result["status"] == 404) {
                        setState((() => _emailInputError = result["msg"]));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          content: Text(result["msg"]),
                          duration: const Duration(seconds: 3),
                        ));
                      } else if (result["status"] == 400) {
                        setState((() => _passwordInputError = result["msg"]));
                      } else if (result["status"] == 500) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(result['msg']),
                          duration: const Duration(seconds: 3),
                        ));
                      } else {
                        await SharedPreferences.getInstance().then((pref) {
                          pref.setString("uid", result["user"]['uid']);
                          Map<String, dynamic> user = result['user'] ;
                          print("user ${user}" );

                          
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(MyUser.fromMap(user))),
                          );
                        });
                      }
                    });
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Signup Button ----------------------------------------------------------
              SizedBox(
                height: _columnItemDistance,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dont't have an account?",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 15,
                        color: Colors.blueGrey),
                  ),
                  TextButton(
                    // "Login",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      "Signup",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 15,
                          color: Color.fromARGB(255, 0, 170, 255)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
