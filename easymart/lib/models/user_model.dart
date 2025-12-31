class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        email: json['email'] ?? '',
        displayName: json['display_name'] ?? json['displayName'] ?? '',
        avatarUrl: json['avatar_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };
}
