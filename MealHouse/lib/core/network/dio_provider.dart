import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/di/injection.dart';
import 'dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return getIt<DioClient>();
});

final dioProvider = Provider((ref) {
  return ref.watch(dioClientProvider).dio;
});

