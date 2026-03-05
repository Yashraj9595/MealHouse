import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, String status) async {
    return await repository.updateOrderStatus(orderId, status);
  }
}
