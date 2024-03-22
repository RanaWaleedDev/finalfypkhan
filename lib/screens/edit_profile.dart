import "package:campus_navigation/models/my_user.dart";
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_storage_web/firebase_storage_web.dart';

Future<void> _saveSelectedFile() async {
  final completer = Completer<Uint8List?>();
  final input = html.FileUploadInputElement();
  input.accept = 'image/*';
  input.click();
  input.onChange.listen((event) async {
    final file = input.files!.first;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((event) async {
      final bytes = reader.result as Uint8List;

      // Write the file bytes to the user's device
      final blob = html.Blob([bytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url);
      anchor.download = file.name;
      anchor.click();

      completer.complete(bytes);
    });
  });

  await completer.future;
}

class EditProfileScreen extends StatefulWidget {
  MyUser myUser;
  EditProfileScreen(this.myUser, {super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController? _emailController;
  TextEditingController? _passwordController;

  MyUser? updatedUser;
  @override
  Widget build(BuildContext context) {
    updatedUser ??= MyUser.fromMap(widget.myUser.toMap());
    _emailController ??= TextEditingController(text: updatedUser?.email);
    _passwordController ??= TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Fake News Dectection",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(widget.myUser.photoUrl!),
                      radius: 50,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 15,
                              ),
                              onPressed: () {
                                _saveSelectedFile();
                              },
                            ),
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    SizedBox(
                      width: 60,
                    ),
                    Text(
                      "Email",
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Email",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 15),
                    ),
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        updatedUser?.email = value;
                      });
                      _emailController?.text = value;
                      _emailController?.selection = TextSelection.fromPosition(
                          TextPosition(offset: _emailController!.text.length));
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    SizedBox(
                      width: 60,
                    ),
                    Text(
                      "Password",
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Password",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 15),
                    ),
                    controller: _passwordController,
                    onChanged: (value) {
                      setState(() {
                        updatedUser?.password = value;
                      });
                      _passwordController?.text = value;
                      _passwordController?.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _passwordController!.text.length));
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.myUser.password!.replaceAll(RegExp("."), "\*"),
                  style: TextStyle(fontSize: 30),
                ),
                Container(
                  decoration: BoxDecoration(
                      // border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  padding:
                      const EdgeInsets.fromLTRB(10, 5, 10, 5), // Add padding

                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        save();
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void save() {
    print("${updatedUser?.email}, ${widget.myUser.email}");
    if (updatedUser?.email != widget.myUser.email) {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      dbRef
          .child("users")
          .orderByChild("email")
          .equalTo(updatedUser?.email)
          .once()
          .then((DatabaseEvent event) {
        print(event.snapshot.value);
        if (event.snapshot.value != null) {
          // email already exists in database
        } else {
          // email doesn't exist in database
          dbRef
              .child("users/${widget.myUser.uid}/email")
              .set(updatedUser?.email)
              .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email updated successfully'),
                duration: Duration(seconds: 3), // Change the duration as needed
              ),
            );
            setState(() {
              widget.myUser.email = updatedUser?.email;
            });
          });
        }
      });
    }

    if (updatedUser?.password != widget.myUser.password) {
      if (updatedUser!.password!.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password Must be 8 length long'),
            duration: Duration(seconds: 3), // Change the duration as needed
          ),
        );
        return;
      }
      DatabaseReference dbRef = FirebaseDatabase.instance.ref();
      dbRef
          .child("users")
          .orderByChild("email")
          .equalTo(updatedUser?.email)
          .once()
          .then((DatabaseEvent event) {
        print(event.snapshot.value);
        if (event.snapshot.value != null) {
          // email already exists in database
        } else {
          // email doesn't exist in database
          dbRef
              .child("users/${widget.myUser.uid}/password")
              .set(updatedUser?.password)
              .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated successfully'),
                duration: Duration(seconds: 3), // Change the duration as needed
              ),
            );
            setState(() {
              widget.myUser.email = updatedUser?.email;
            });
          });
        }
      });
    }
  }
}
