import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/mess_profile_entity.dart';
import '../../domain/repositories/mess_profile_repository.dart';
import '../../domain/usecases/get_mess_profile_usecase.dart';
import '../../domain/usecases/update_mess_profile_usecase.dart';
import '../../data/repositories/mess_profile_repository_impl.dart';

// Reuse the global dio provider if available, or create local
// Assuming a global dioProvider is available in core/di/injection_container.dart or similar, 
// but for now I'll use the one I defined in meal_providers.dart or define here if needed.
// Actually, I should probably reuse the one from `meal_providers.dart` or create a shared one.
// To avoid circular deps or confusion, I'll assume a `dioProvider` is available or just define a basic one here for now.
// Ideally, `dioProvider` should be in a core location.

import 'package:MealHouse/core/network/dio_provider.dart';

final messProfileRepositoryProvider = Provider<MessProfileRepository>((ref) {
  return MessProfileRepositoryImpl(dio: ref.watch(dioProvider));
});

final getMessProfileUseCaseProvider = Provider((ref) => GetMessProfileUseCase(ref.watch(messProfileRepositoryProvider)));
final updateMessProfileUseCaseProvider = Provider((ref) => UpdateMessProfileUseCase(ref.watch(messProfileRepositoryProvider)));

final messProfileProvider = FutureProvider<MessProfileEntity>((ref) async {
  final useCase = ref.watch(getMessProfileUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (profile) => profile,
  );
});
