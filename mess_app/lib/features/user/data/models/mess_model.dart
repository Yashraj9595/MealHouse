class MessModel {
  final String id;
  final String name;
  final String owner;
  final String? description;
  final String image;
  final double rating;
  final String cuisine;
  final String deliveryTime;
  final String distance;
  final String price;
  final bool isVeg;
  final bool isActive;

  MessModel({
    required this.id,
    required this.name,
    required this.owner,
    this.description,
    required this.image,
    required this.rating,
    required this.cuisine,
    required this.deliveryTime,
    required this.distance,
    required this.price,
    required this.isVeg,
    this.isActive = true,
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      owner: json['owner'] is String ? json['owner'] : (json['owner']['_id'] ?? ''),
      description: json['description'],
      image: json['image'] ?? 'https://images.unsplash.com/photo-1625398407796-82650a8c135f',
      rating: (json['rating'] ?? 4.0).toDouble(),
      cuisine: json['cuisine'] ?? 'Indian',
      deliveryTime: json['deliveryTime'] ?? '20-30 min',
      distance: json['distance'] ?? '1.0 km',
      price: json['price']?.toString() ?? '100',
      isVeg: json['isVeg'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'cuisine': cuisine,
      'isVeg': isVeg,
    };
  }
}
