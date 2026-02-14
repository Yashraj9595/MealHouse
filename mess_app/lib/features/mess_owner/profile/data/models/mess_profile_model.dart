import '../../domain/entities/mess_profile_entity.dart';

class MessProfileModel extends MessProfileEntity {
  MessProfileModel({
    required String id,
    required String messName,
    required String address,
    required String phoneNumber,
    String? description,
    required List<String> images,
    required String operatingHours,
    required bool isVegOnly,
    double rating = 0.0,
    String? locationUrl,
  }) : super(
          id: id,
          messName: messName,
          address: address,
          phoneNumber: phoneNumber,
          description: description,
          images: images,
          operatingHours: operatingHours,
          isVegOnly: isVegOnly,
          rating: rating,
          locationUrl: locationUrl,
        );

  factory MessProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper to format address from object if necessary, or just use string
    // Assuming backend returns address object {street, city, ...} or string
    String formattedAddress = '';
    if (json['address'] is Map) {
      final addr = json['address'];
      formattedAddress = '${addr['street']}, ${addr['city']}, ${addr['state']}';
    } else {
      formattedAddress = json['address']?.toString() ?? '';
    }

    String formattedHours = '';
    if (json['openingHours'] is Map) {
      final hours = json['openingHours'];
      // Simply joining for display, or could be more complex
      formattedHours = 'Breakfast: ${hours['breakfast']?['start']}-${hours['breakfast']?['end']}, Lunch: ${hours['lunch']?['start']}-${hours['lunch']?['end']}, Dinner: ${hours['dinner']?['start']}-${hours['dinner']?['end']}'; 
    } else {
      formattedHours = json['openingHours']?.toString() ?? '';
    }
    
    // Contact mapping
    String phone = '';
    if (json['contact'] is Map) {
      phone = json['contact']['phone']?.toString() ?? '';
    } else {
       phone = json['phone']?.toString() ?? '';
    }

    return MessProfileModel(
      id: json['_id'] ?? '',
      messName: json['name'] ?? '',
      address: formattedAddress,
      phoneNumber: phone,
      description: json['description'],
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      operatingHours: formattedHours,
      isVegOnly: json['mealType'] == 'veg',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      locationUrl: '', // Add logic if location URL available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': messName,
      'description': description,
      // 'address': address, // Complex mapping back to object might be needed for update
      'contact': {'phone': phoneNumber},
      // 'openingHours': operatingHours, // Similarly complex
      'mealType': isVegOnly ? 'veg' : 'both', // Simplified
    };
  }
}
