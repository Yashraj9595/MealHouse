import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? profileImage;
  final List<SavedLocation>? savedLocations;
  final PickupPreferences? pickupPreferences;
  final String role;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.profileImage,
    this.savedLocations,
    this.pickupPreferences,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? mobile,
    String? profileImage,
    List<SavedLocation>? savedLocations,
    PickupPreferences? pickupPreferences,
    String? role,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
      savedLocations: savedLocations ?? this.savedLocations,
      pickupPreferences: pickupPreferences ?? this.pickupPreferences,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        mobile,
        profileImage,
        savedLocations,
        pickupPreferences,
        role,
        isActive,
        isEmailVerified,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role)';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] ?? json['_id'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      mobile: (json['mobile'] ?? '') as String,
      profileImage: json['profileImage'] as String?,
      savedLocations: json['savedLocations'] != null
          ? (json['savedLocations'] as List)
              .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pickupPreferences: json['pickupPreferences'] != null
          ? PickupPreferences.fromJson(
              json['pickupPreferences'] as Map<String, dynamic>)
          : null,
      role: (json['role'] ?? 'user') as String,
      isActive: json['isActive'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
      'profileImage': profileImage,
      'savedLocations': savedLocations?.map((e) => e.toJson()).toList(),
      'pickupPreferences': pickupPreferences?.toJson(),
      'role': role,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SavedLocation extends Equatable {
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? icon;

  const SavedLocation({
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    this.icon,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      label: (json['label'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [label, address, latitude, longitude, icon];
}

class PickupPreferences extends Equatable {
  final String? breakfast;
  final String? lunch;
  final String? dinner;

  const PickupPreferences({
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  factory PickupPreferences.fromJson(Map<String, dynamic> json) {
    return PickupPreferences(
      breakfast: json['breakfast'] as String?,
      lunch: json['lunch'] as String?,
      dinner: json['dinner'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  @override
  List<Object?> get props => [breakfast, lunch, dinner];
}
