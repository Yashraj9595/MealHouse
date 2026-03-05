import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/network/dio_provider.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/repositories/order_repository.dart';
import 'package:MealHouse/features/mess_owner/order_management/data/repositories/order_repository_impl.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/usecases/get_orders_usecase.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/usecases/update_order_status_usecase.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';

// Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(dio: ref.watch(dioProvider));
});

// Use Case Providers
final getOrdersUseCaseProvider = Provider((ref) => GetOrdersUseCase(ref.watch(orderRepositoryProvider)));
final updateOrderStatusUseCaseProvider = Provider((ref) => UpdateOrderStatusUseCase(ref.watch(orderRepositoryProvider)));

// State Provider for Orders List
final ordersListProvider = FutureProvider.autoDispose<List<OrderEntity>>((ref) async {
  final useCase = ref.watch(getOrdersUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (orders) => orders,
  );
});
