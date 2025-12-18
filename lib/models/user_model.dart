class UserModel {
  final String uid;
  final String email;
  final String displayName;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  factory UserModel.fromFirebaseUser(dynamic user) {
    final email = user.email ?? '';
    String displayName = user.displayName ?? '';

    if (displayName.isEmpty) {
      displayName = email.isNotEmpty ? email : 'Usuário';
    }

    return UserModel(
      uid: user.uid,
      email: email,
      displayName: displayName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final email = map['email'] ?? '';
    String displayName = map['displayName'] ?? '';

    if (displayName.isEmpty) {
      displayName = email.isNotEmpty ? email : 'Usuário';
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: email,
      displayName: displayName,
    );
  }
}
