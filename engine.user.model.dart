class EngineUser {
  String email;
  String displayName;
  String phoneNumber;
  String photoURL;
  String birthday;
  bool isAdmin;
  List<dynamic> urls;
  EngineUser({
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.birthday,
    this.urls,
    this.isAdmin,
  }) {
    if (urls == null) urls = [];
  }
  factory EngineUser.fromEngineData(Map<dynamic, dynamic> data) {
    return EngineUser(
      email: data['email'],
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      birthday: data['birthday'],
      isAdmin: data['admin'] ?? false,
      urls: data['urls'] != null
          ? List<dynamic>.from(data['urls'])
          : [], // To preved 'fixed-length' error.
    );
  }

  @override
  String toString() {
    return "email: $email\nisAdmin: $isAdmin\ndisplayName:$displayName\nphoneNumber:$phoneNumber\nphotoURL:$photoURL\nbirthday:$birthday";
  }
}
