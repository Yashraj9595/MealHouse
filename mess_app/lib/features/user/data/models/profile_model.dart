class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profileImage;
  final String? address;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profileImage,
    this.address,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'user',
      profileImage: json['profileImage'],
      address: json['address'],
    );
  }
}
