import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../data/repositories/user_profile_repository_impl.dart';

import 'package:MealHouse/core/network/dio_provider.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(dio: ref.watch(dioProvider));
});

final getUserProfileUseCaseProvider = Provider((ref) => GetUserProfileUseCase(ref.watch(userProfileRepositoryProvider)));
final updateUserProfileUseCaseProvider = Provider((ref) => UpdateUserProfileUseCase(ref.watch(userProfileRepositoryProvider)));

final userProfileProvider = FutureProvider<UserProfileEntity>((ref) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (profile) => profile,
  );
});
