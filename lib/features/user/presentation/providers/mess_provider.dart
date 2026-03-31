import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_house/core/services/location_service.dart';
import '../../../mess_owner/domain/models/mess_model.dart';
import '../../../mess_owner/domain/models/menu_model.dart';
import '../../../mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/core/di/service_locator.dart';


class MessState {
  final List<MessModel> messes;
  final bool isLoading;
  final String? error;

  MessState({
    this.messes = const [],
    this.isLoading = false,
    this.error,
  });

  MessState copyWith({
    List<MessModel>? messes,
    bool? isLoading,
    String? error,
  }) {
    return MessState(
      messes: messes ?? this.messes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MessNotifier extends Notifier<MessState> {
  @override
  MessState build() {
    return MessState();
  }

  MessRepository get _repository => sl<MessRepository>();

  Future<void> fetchMesses({double? lat, double? lng, double? radius, String? cuisine}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messes = await _repository.getMesses(
        lat: lat,
        lng: lng,
        radius: radius,
        cuisine: cuisine,
      );
      state = state.copyWith(messes: messes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMyMesses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messes = await _repository.getMyMesses();
      state = state.copyWith(messes: messes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final messProvider = NotifierProvider<MessNotifier, MessState>(() {
  return MessNotifier();
});

final locationProvider = StreamProvider.autoDispose<Position?>((ref) {
  final controller = StreamController<Position?>();
  
  // Initial value
  controller.add(LocationService.selectedPosition.value);
  
  // Listen to changes
  void listener() => controller.add(LocationService.selectedPosition.value);
  LocationService.selectedPosition.addListener(listener);
  
  ref.onDispose(() {
    LocationService.selectedPosition.removeListener(listener);
    controller.close();
  });
  
  return controller.stream;
});

final nearbyMessesProvider = FutureProvider.autoDispose<List<MessModel>>((ref) async {
  final repository = sl<MessRepository>();
  final locationAsync = ref.watch(locationProvider);
  
  final position = locationAsync.value ?? LocationService.selectedPosition.value;
  
  if (position != null) {
    // Fetch real nearby messes using coordinates
    return await repository.getMesses(
      lat: position.latitude,
      lng: position.longitude,
      radius: 10000.0, // 10km radius (in meters)
    );
  }
  
  // Default fallback if no location confirmed
  return await repository.getMesses();
});


class RecommendedThaliModel {
  final MessModel mess;
  final MenuItemModel item;
  final double? distance;

  RecommendedThaliModel({
    required this.mess,
    required this.item,
    this.distance,
  });

  String get distanceString {
    if (distance == null) return 'Nearby';
    if (distance! < 1000) return '${distance!.toInt()}m away';
    return '${(distance! / 1000).toStringAsFixed(1)}km away';
  }
}

final recommendedThalisProvider = FutureProvider.autoDispose<List<RecommendedThaliModel>>((ref) async {
  final messes = await ref.watch(nearbyMessesProvider.future);
  final locationAsync = ref.watch(locationProvider);
  final repository = sl<MessRepository>();
  
  final position = locationAsync.value ?? LocationService.selectedPosition.value;
  
  // Concurrently fetch menus to avoid large sequential load times
  final menuFutures = messes
      .where((m) => m.id != null)
      .map((m) => repository.getMenu(m.id!).then((menu) => {'mess': m, 'menu': menu}))
      .toList();

  final results = await Future.wait(menuFutures);
  final List<RecommendedThaliModel> allThalis = [];
  
  for (final res in results) {
    final mess = res['mess'] as MessModel;
    final menu = res['menu'] as MenuModel;
    
    double? dist;
    if (position != null && mess.latitude != null && mess.longitude != null) {
      dist = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        mess.latitude!,
        mess.longitude!,
      );
    }

    for (final item in menu.items) {
      if (item.isAvailable) {
        allThalis.add(RecommendedThaliModel(
          mess: mess,
          item: item,
          distance: dist,
        ));
      }
    }
  }

  // Sort by distance (if available) then popularity/price?
  allThalis.sort((a, b) {
    if (a.distance != null && b.distance != null) {
      return a.distance!.compareTo(b.distance!);
    }
    return 0;
  });

  return allThalis;
});
