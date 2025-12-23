class User {
  final String? id;
  final String? nic;
  final String? title;
  final String? name;
  final String? role;
  final String? contact;
  // Add other fields from your JWT token as needed

  User({this.id, this.nic, this.title, this.name, this.role, this.contact});

  factory User.fromToken(Map<String, dynamic> decodedToken) {
    return User(
      id: decodedToken['id'] as String?,
      nic: decodedToken['nic'] as String?,
      title: decodedToken['title'] as String?,
      name: decodedToken['name'] as String?,
      role: decodedToken['role'] as String?,
      contact: decodedToken['contact'] as String?,
      // Map other fields from your token
    );
  }

  bool get emptyFields => title == null || title!.isEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nic': nic,
    'title': title,
    'name': name,
    'role': role,
    'contact': contact,
  };
}
