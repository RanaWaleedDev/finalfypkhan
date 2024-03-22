import 'package:campus_navigation/models/my_user.dart';
import 'package:campus_navigation/screens/auth/login_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final databaseReference = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> _saveUserData(
      String email, String password, String photoUrl) async {
    try {
      // Check if user with the given email already exists
      DataSnapshot snapshot = (await databaseReference
              .child('users')
              .orderByChild('email')
              .equalTo(email)
              .once())
          .snapshot;
      if (snapshot.value != null) {
        // User already exists
        return {"status": 409, "msg": 'Username or email already exists'};
      }
      // Check if the password is at least 8 characters long
      if (password.length < 8) {
        return {
          "status": 400,
          "msg": "Password should be at least 8 characters long"
        }; // 400: bad request
      }

      // Generate a new unique key for the object
      String? key = databaseReference.child('users').push().key;

      // Create the object with the unique key
      Map<String, dynamic> userData = {
        "uid": key!,
        'email': email,
        'password': password,
        'photoUrl': photoUrl
      };

      // Save the object to the database
      await databaseReference.child('users').child(key).set(userData);

      // Return success message
      return {
        "status": 200,
        "msg": 'User created successfully',
        "user": userData
      };
    } catch (error) {
      // Return error message
      return {"status": 500, "msg": 'Error creating user'};
    }
  }

  String _emailInputError = "", _passwordInputError = "";
  final double _columnItemDistance = 20;
  String _emailInput = "", _passwordInput = "";
  bool _showPassword = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _db.connect();
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
                "Create an account",
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
                "Email or Username",
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
                    hintText: "Enter Email or Username",
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
                    "Forgot?",
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
                    _saveUserData(_emailInput.trim(), _passwordInput.trim(),
                            "gs://campus-navigation-2f274.appspot.com/default-items/user/avatar.png")
                        .then((result) async {
                      if (result["status"] == 409) {
                        setState(() => _emailInputError = result['msg']);
                      } else if (result["status"] == 400) {
                        setState(() => _passwordInputError = result['msg']);
                      } else if (result["status"] == 500) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Something went wrong!'),
                          duration: Duration(seconds: 3),
                        ));
                      } else {
                        await SharedPreferences.getInstance().then((prefs) {
                          prefs.setString('uid', result["user"]["uid"]);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(MyUser.fromMap(result))),
                          );
                        });
                      }
                    });
                  },
                  child: const Text(
                    "Create account",
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
                    "Already have an account?",
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 15,
                        color: Colors.blueGrey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Login",
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
