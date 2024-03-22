import "package:campus_navigation/models/my_user.dart";
import "package:campus_navigation/screens/edit_profile.dart";
import "package:flutter/material.dart";

class SettingScreen extends StatefulWidget {
  MyUser myUser;
  SettingScreen(this.myUser, {super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                // Element on the right goes here
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                          // border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue),
                      padding: const EdgeInsets.fromLTRB(
                          10, 5, 10, 5), // Add padding

                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen(widget.myUser)));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CircleAvatar(
              backgroundImage: AssetImage(widget.myUser.photoUrl!),
              radius: 50,
            ),
            SizedBox(
              height: 20,
            ),

            Text(
              'Hamza Khan',
              style: TextStyle(fontSize: 30),
            ),

            // Text(
            //   widget.myUser.email!.split("@")[0].toUpperCase(),
            //   style: TextStyle(fontSize: 30),
            // ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.myUser.password!.replaceAll(RegExp("."), "\*"),
              style: TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
