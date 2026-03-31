import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mess_model.dart';
import '../../domain/repositories/mess_repository.dart';
import 'package:meal_house/core/di/service_locator.dart';

class MessRegistrationState {
  final String name;
  final String ownerName;
  final String mobile;
  final String description;
  final String cuisineType;
  final String address;
  final double longitude;
  final double latitude;
  final String? logo;
  final List<String> photos;
  final List<OperatingHoursModel>? operatingHours;
  final bool isLoading;
  final String? error;

  MessRegistrationState({
    this.name = '',
    this.ownerName = '',
    this.mobile = '',
    this.description = '',
    this.cuisineType = 'Mixed',
    this.address = '',
    this.longitude = 0.0,
    this.latitude = 0.0,
    this.logo,
    this.photos = const [],
    this.operatingHours,
    this.isLoading = false,
    this.error,
  });

  MessRegistrationState copyWith({
    String? name,
    String? ownerName,
    String? mobile,
    String? description,
    String? cuisineType,
    String? address,
    double? longitude,
    double? latitude,
    String? logo,
    List<String>? photos,
    List<OperatingHoursModel>? operatingHours,
    bool? isLoading,
    String? error,
  }) {
    return MessRegistrationState(
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      mobile: mobile ?? this.mobile,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      address: address ?? this.address,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      logo: logo ?? this.logo,
      photos: photos ?? this.photos,
      operatingHours: operatingHours ?? this.operatingHours,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MessRegistrationNotifier extends Notifier<MessRegistrationState> {
  @override
  MessRegistrationState build() {
    return MessRegistrationState();
  }

  MessRepository get _repository => sl<MessRepository>();

  void updateDetails({
    String? name,
    String? ownerName,
    String? mobile,
    String? description,
    String? cuisineType,
  }) {
    state = state.copyWith(
      name: name,
      ownerName: ownerName,
      mobile: mobile,
      description: description,
      cuisineType: cuisineType,
    );
  }

  void updateLocation({
    String? address,
    double? longitude,
    double? latitude,
  }) {
    state = state.copyWith(
      address: address,
      longitude: longitude,
      latitude: latitude,
    );
  }

  void updatePhotos(List<String> photos) {
    state = state.copyWith(photos: photos);
  }

  void updateLogo(String logo) {
    state = state.copyWith(logo: logo);
  }

  void updateOperatingHours(List<OperatingHoursModel> operatingHours) {
    state = state.copyWith(operatingHours: operatingHours);
  }

  Future<bool> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final mess = MessModel(
        name: state.name,
        ownerName: state.ownerName,
        ownerId: '', // Will be set by backend from token
        mobile: state.mobile,
        description: state.description,
        cuisineType: state.cuisineType,
        address: state.address,
        longitude: state.longitude,
        latitude: state.latitude,
        logo: state.logo,
        photos: state.photos,
        operatingHours: state.operatingHours,
      );
      
      await _repository.createMess(mess);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final messRegistrationProvider = NotifierProvider<MessRegistrationNotifier, MessRegistrationState>(() {
  return MessRegistrationNotifier();
});
