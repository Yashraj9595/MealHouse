import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();
  Future<Either<Failure, void>> updateOrderStatus(String orderId, String status);
}
