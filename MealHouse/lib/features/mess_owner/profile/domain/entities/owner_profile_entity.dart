class OwnerProfileEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String? bio;

  OwnerProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    this.bio,
  });
}
