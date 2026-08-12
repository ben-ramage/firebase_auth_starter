class AppUser {
  final String uid;
  final String name;
  final String email;

  AppUser({required this.uid, required this.name, required this.email});

  // Convert the App User to JSON:
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'email': email};
  }

  // Convert JSON to App User:
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'] as String,
      name: jsonUser['name'] as String,
      email: jsonUser['email'] as String,
    );
  }
}
