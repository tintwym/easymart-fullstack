class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? image;   // Url to profile image
  final String? phone;   // <--- NEW
  final String? address; // <--- NEW
  final String? bio;     // <--- NEW

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.image,
    this.phone,
    this.address,
    this.bio,
  });

  // Factory constructor to create a UserModel from JSON (Backend response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'],
      phone: json['phone'],       // <--- NEW
      address: json['address'],   // <--- NEW
      bio: json['bio'],           // <--- NEW
    );
  }

  // Method to convert UserModel to JSON (To send to Backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'image': image,
      'phone': phone,       // <--- NEW
      'address': address,   // <--- NEW
      'bio': bio,           // <--- NEW
    };
  }
}