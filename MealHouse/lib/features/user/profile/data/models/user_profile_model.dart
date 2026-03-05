import '../../domain/entities/profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    String formattedAddress = '';
    if (json['address'] is Map) {
      final addr = json['address'];
      formattedAddress = '${addr['street'] ?? ''}, ${addr['city'] ?? ''}, ${addr['state'] ?? ''}, ${addr['pincode'] ?? ''}';
      // Clean up commas if fields are empty
      formattedAddress = formattedAddress.replaceAll(RegExp(r'^, | , |,$'), '').trim();
    } else {
      formattedAddress = json['address']?.toString() ?? '';
    }

    return UserProfileModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone']?.toString() ?? '',
      address: formattedAddress,
    );
  }

  Map<String, dynamic> toJson() {
    // Basic implementation - for full update, address usually needs strict structure
    // We might need to parse the address string back to object or just send what we have if backend accepts string (unlikely).
    // For now, sending keys that are updatable.
    
    // Attempt to split address? Or just send as is if backend allows?
    // Given API_TESTING.md shows address object, we should ideally use that.
    // But since our Entity uses String for simplicity in UI, we might face issue here.
    // I will try to parse basic commas, else send as single field if allowed or partial.
    // Safest is to just update name and phone for now, or assume address is not editable via this simple string.
    // OR: create a dummy object.
    
    // Let's try to assume logic: Street, City, State, Pincode
    final parts = address.split(',').map((e) => e.trim()).toList();
    final addressObj = {};
    if (parts.isNotEmpty) addressObj['street'] = parts[0];
    if (parts.length > 1) addressObj['city'] = parts[1];
    if (parts.length > 2) addressObj['state'] = parts[2];
    if (parts.length > 3) addressObj['pincode'] = parts[3];

    return {
      'name': name,
      'phone': phoneNumber,
      if (parts.isNotEmpty) 'address': addressObj,
    };
  }
}
