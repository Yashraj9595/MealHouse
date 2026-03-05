import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MealHouse/core/network/dio_client.dart';
import 'package:MealHouse/core/services/secure_storage_service.dart';
import 'package:MealHouse/features/user/domain/repositories/mess_repository.dart';
import 'package:MealHouse/features/user/data/repositories/mess_repository_impl.dart';
import 'package:MealHouse/features/user/domain/repositories/user_repository.dart';
import 'package:MealHouse/features/user/data/repositories/user_repository_impl.dart';
import 'package:MealHouse/features/mess_owner/domain/repositories/mess_owner_repository.dart';
import 'package:MealHouse/features/mess_owner/data/repositories/mess_owner_repository_impl.dart';
import 'package:MealHouse/features/auth/domain/repositories/auth_repository.dart';
import 'package:MealHouse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:MealHouse/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:MealHouse/features/mess_owner/meal_management/domain/repositories/meal_repository.dart';
import 'package:MealHouse/features/mess_owner/meal_management/data/repositories/meal_repository_impl.dart';
import 'package:MealHouse/features/mess_owner/meal_management/data/datasource/meal_remote_datasource.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  
  // Core Services
  getIt.registerLazySingleton(() => SecureStorageService());
  getIt.registerLazySingleton(() => DioClient(storageService: getIt()));
  
  // Auth DataSource & Repository
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      storageService: getIt(),
    ),
  );
  
  // Meal DataSource & Repository
  getIt.registerLazySingleton<MealRemoteDataSource>(
    () => MealRemoteDataSourceImpl(dioClient: getIt()),
  );
  getIt.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(remoteDataSource: getIt()),
  );
  
  // Other Repositories
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
