class MyUser {
  String? uid;
  String? email;
  String? password;
  String? photoUrl;

  MyUser({
    required this.uid,
    required this.email,
    required this.password,
    required this.photoUrl,
  });

  MyUser.fromUIDAndEmail({required this.uid, required this.email});

  factory MyUser.fromMap(Map<dynamic, dynamic> map) {
    return MyUser(
      uid: map['uid'],
      email: map['email'],
      password: map['password'],
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'photoUrl': photoUrl,
    };
  }
}
