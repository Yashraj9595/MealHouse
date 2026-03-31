import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:meal_house/core/constants/meal_enum.dart';

class LocationService {
  /// Reactive notifier for the currently selected location string
  static final ValueNotifier<String> selectedLocation = 
      ValueNotifier<String>('Locating...');

  /// Reactive notifier for the coordinates of the selected location
  static final ValueNotifier<Position?> selectedPosition = 
      ValueNotifier<Position?>(null);

  /// Automatically detect and update current location
  Future<void> autoDetectLocation() async {
    final position = await getCurrentPosition();
    if (position != null) {
      selectedPosition.value = position;
      final placemark = await getAddressFromLatLng(position);
      if (placemark != null) {
        selectedLocation.value = formatAddress(placemark);
      }
    } else {
      selectedLocation.value = 'Select Location';
    }
  }

  /// Map to store confirmed locations per meal type
  static final Map<MealType, String> _confirmedNames = {};
  static final Map<MealType, Position?> _confirmedPositions = {};

  /// Update the global selected location and position, optionally for a specific meal
  void updateLocation(String name, {Position? position, MealType? forMeal}) {
    selectedLocation.value = name;
    if (position != null) {
      selectedPosition.value = position;
    }
    
    if (forMeal != null) {
      _confirmedNames[forMeal] = name;
      _confirmedPositions[forMeal] = position;
    }
  }

  /// Switch the active global location to the one confirmed for a specific meal
  void switchToMealLocation(MealType meal) {
    if (_confirmedNames.containsKey(meal)) {
      selectedLocation.value = _confirmedNames[meal]!;
      selectedPosition.value = _confirmedPositions[meal];
    }
  }

  /// Update just the global selected location name
  void updateSelectedLocation(String newLocation) {
    selectedLocation.value = newLocation;
  }
  /// Request permission and get current position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Convert position to readable address
  Future<Placemark?> getAddressFromLatLng(Position position) async {
    if (kIsWeb) {
      try {
        // Use OpenStreetMap Nominatim for Web geocoding
        final response = await Dio().get(
          'https://nominatim.openstreetmap.org/reverse',
          queryParameters: {
            'format': 'json',
            'lat': position.latitude,
            'lon': position.longitude,
            'zoom': 18,
            'addressdetails': 1,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final addr = response.data['address'] ?? {};
          final displayName = response.data['display_name'] ?? '';
          
          // Nominatim address parts vary by region
          final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['municipality'] ?? addr['county'] ?? '';
          final suburb = addr['suburb'] ?? addr['neighbourhood'] ?? addr['residential'] ?? addr['road'] ?? '';
          final state = addr['state'] ?? addr['state_district'] ?? '';
          final postcode = addr['postcode'] ?? '';

          return Placemark(
            name: suburb.isNotEmpty ? suburb : (addr['road'] ?? ''),
            subLocality: addr['neighbourhood'] ?? addr['suburb'] ?? '',
            locality: city,
            administrativeArea: state,
            postalCode: postcode,
            street: displayName,
          );
        }
      } catch (e) {
        debugPrint('Web geocoding error: $e');
      }
      
      return const Placemark(
        name: 'Manual Entry Required',
        locality: 'Web Browser',
      );
    }
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks[0];
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
    return null;
  }

  /// Format Placemark to a string
  String formatAddress(Placemark place) {
    String subLocality = place.subLocality ?? '';
    String locality = place.locality ?? '';
    String administrativeArea = place.administrativeArea ?? '';
    String postalCode = place.postalCode ?? '';

    // Build a clean address string
    List<String> segments = [];
    if (subLocality.isNotEmpty) segments.add(subLocality);
    if (locality.isNotEmpty) segments.add(locality);
    if (administrativeArea.isNotEmpty) segments.add(administrativeArea);
    if (postalCode.isNotEmpty) segments.add(postalCode);
    
    // Fallback to name if segments are empty
    if (segments.isEmpty) return place.name ?? 'Unknown Location';
    
    // If on web, we often have a better full street address in 'street'
    if (kIsWeb && place.street != null && place.street!.length > 10) {
       return place.street!;
    }
    
    return segments.join(', ');
  }
}
