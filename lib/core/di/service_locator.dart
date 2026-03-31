import 'package:get_it/get_it.dart';
import 'package:meal_house/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:meal_house/features/auth/data/services/auth_service.dart';
import 'package:meal_house/features/auth/domain/repositories/auth_repository.dart';
import 'package:meal_house/features/auth/domain/usecases/login_usecase.dart';
import 'package:meal_house/features/auth/domain/usecases/register_usecase.dart';
import 'package:meal_house/features/auth/domain/usecases/logout_usecase.dart';
import 'package:meal_house/core/network/api_client.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/features/mess_owner/data/services/mess_service.dart';
import 'package:meal_house/features/mess_owner/data/repositories/mess_repository_impl.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/pickup_points/data/services/pickup_service.dart';
import 'package:meal_house/features/order/data/services/order_service.dart';
import 'package:meal_house/features/order/data/repositories/order_repository_impl.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<LocationService>(() => LocationService());
  
  // Auth services
  sl.registerLazySingleton<AuthService>(() => AuthService(sl()));
  
  // Auth repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  
  // Auth use cases
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  
  
  // Mess services
  sl.registerLazySingleton<MessService>(() => MessService(sl()));
  
  // Mess repositories
  sl.registerLazySingleton<MessRepository>(() => MessRepositoryImpl(sl()));
  
  // Pickup services
  sl.registerLazySingleton<PickupService>(() => PickupService(sl()));
  
  // Order services
  sl.registerLazySingleton<OrderService>(() => OrderService(sl()));
  // Order repositories
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));
  
  // Additional services can be registered here as the app grows
  // Example: User services, Order services, Wallet services, etc.
}

// Extension for easy access to services
extension ServiceLocator on GetIt {
  T get<T extends Object>() => sl<T>();
}

// Cleanup function
Future<void> cleanupDependencies() async {
  await sl.reset();
}
