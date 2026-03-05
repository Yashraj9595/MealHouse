import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final AddressEntity? address;
  final String? token;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.token,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, profileImage, address, token];
}

class AddressEntity extends Equatable {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const AddressEntity({
    this.street,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [street, city, state, pincode, latitude, longitude];
}
