class EnginfUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoURL;
  String birthday;
  EnginfUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.birthday,
  });
  factory EnginfUser.fromMap(Map<dynamic, dynamic> data) {
    return EnginfUser(
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      birthday: data['birthday'],
    );
  }

  @override
  String toString() {
    return "$email\n$displayName\n$phoneNumber\n$photoURL\n$birthday";
  }
}
