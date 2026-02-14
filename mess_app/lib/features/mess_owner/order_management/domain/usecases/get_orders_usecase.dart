import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call() async {
    return await repository.getOrders();
  }
}
