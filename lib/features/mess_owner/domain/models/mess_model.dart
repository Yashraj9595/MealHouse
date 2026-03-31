class OperatingHoursModel {
  final String day;
  final bool isOpen;
  final MealTimeModel? breakfast;
  final MealTimeModel? lunch;
  final MealTimeModel? dinner;

  OperatingHoursModel({
    required this.day,
    required this.isOpen,
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  factory OperatingHoursModel.fromJson(Map<String, dynamic> json) {
    return OperatingHoursModel(
      day: json['day'] ?? '',
      isOpen: json['isOpen'] ?? false,
      breakfast: json['breakfast'] != null ? MealTimeModel.fromJson(json['breakfast']) : null,
      lunch: json['lunch'] != null ? MealTimeModel.fromJson(json['lunch']) : null,
      dinner: json['dinner'] != null ? MealTimeModel.fromJson(json['dinner']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isOpen': isOpen,
      if (breakfast != null) 'breakfast': breakfast!.toJson(),
      if (lunch != null) 'lunch': lunch!.toJson(),
      if (dinner != null) 'dinner': dinner!.toJson(),
    };
  }
}

class MealTimeModel {
  final String start;
  final String end;

  MealTimeModel({required this.start, required this.end});

  factory MealTimeModel.fromJson(Map<String, dynamic> json) {
    return MealTimeModel(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class MessModel {
  final String? id;
  final String name;
  final String ownerName;
  final String ownerId;
  final String mobile;
  final String description;
  final String cuisineType;
  final String address;
  final double longitude;
  final double latitude;
  final List<String> photos;
  final String? logo;
  final double rating;
  final int numReviews;
  final bool isApproved;
  final bool isActive;
  final List<OperatingHoursModel>? operatingHours;

  MessModel({
    this.id,
    required this.name,
    required this.ownerName,
    required this.ownerId,
    required this.mobile,
    required this.description,
    required this.cuisineType,
    required this.address,
    required this.longitude,
    required this.latitude,
    this.photos = const [],
    this.logo,
    this.rating = 0.0,
    this.numReviews = 0,
    this.isApproved = false,
    this.isActive = true,
    this.operatingHours,
  });

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      id: json['_id'],
      name: json['name'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      mobile: json['mobile'] ?? '',
      description: json['description'] ?? '',
      cuisineType: json['cuisineType'] ?? '',
      address: json['address'] ?? '',
      longitude: json['location'] != null && json['location']['coordinates'] != null 
          ? (json['location']['coordinates'][0] as num).toDouble() 
          : 0.0,
      latitude: json['location'] != null && json['location']['coordinates'] != null
          ? (json['location']['coordinates'][1] as num).toDouble()
          : 0.0,
      photos: List<String>.from(json['photos'] ?? []),
      logo: json['logo'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      numReviews: json['numReviews'] ?? 0,
      isApproved: json['isApproved'] ?? false,
      isActive: json['isActive'] ?? true,
      operatingHours: json['operatingHours'] != null
          ? List<OperatingHoursModel>.from(
              json['operatingHours'].map((x) => OperatingHoursModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'ownerName': ownerName,
      'ownerId': ownerId,
      'mobile': mobile,
      'description': description,
      'cuisineType': cuisineType,
      'address': address,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'photos': photos,
      if (logo != null) 'logo': logo,
      'rating': rating,
      'numReviews': numReviews,
      'isApproved': isApproved,
      'isActive': isActive,
      if (operatingHours != null)
        'operatingHours': operatingHours!.map((x) => x.toJson()).toList(),
    };
  }
}
