import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/entities/user.dart';

final profileProvider = FutureProvider.autoDispose<User?>((ref) async {
  final repository = sl<AuthRepository>();
  return await repository.getCurrentUser();
});
