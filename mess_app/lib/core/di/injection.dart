import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MealHouse/core/network/dio_client.dart';
import 'package:MealHouse/features/user/domain/repositories/mess_repository.dart';
import 'package:MealHouse/features/user/data/repositories/mess_repository_impl.dart';
import 'package:MealHouse/features/user/domain/repositories/user_repository.dart';
import 'package:MealHouse/features/user/data/repositories/user_repository_impl.dart';
import 'package:MealHouse/features/mess_owner/domain/repositories/mess_owner_repository.dart';
import 'package:MealHouse/features/mess_owner/data/repositories/mess_owner_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  
  // Core
  getIt.registerLazySingleton(() => DioClient());
  
  // Repositories
  getIt.registerLazySingleton<MessRepository>(
    () => MessRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<MessOwnerRepository>(
    () => MessOwnerRepositoryImpl(getIt()),
  );
}
