class MessProfileEntity {
  final String id;
  final String messName;
  final String address;
  final String phoneNumber;
  final String? description;
  final List<String> images;
  final String operatingHours;
  final bool isVegOnly;
  final double rating;
  final String? locationUrl;

  MessProfileEntity({
    required this.id,
    required this.messName,
    required this.address,
    required this.phoneNumber,
    this.description,
    required this.images,
    required this.operatingHours,
    required this.isVegOnly,
    this.rating = 0.0,
    this.locationUrl,
  });
}
