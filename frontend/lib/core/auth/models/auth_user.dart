class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.phoneNumber,
    this.photo,
  });

  final int id;
  final String name;
  final String email;
  final String? gender;
  final String? phoneNumber;
  final String? photo;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      gender: json['gender'] as String?,
      phoneNumber: json['no_telp'] as String?,
      photo: json['foto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'no_telp': phoneNumber,
      'foto': photo,
    };
  }
}
