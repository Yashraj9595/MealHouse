import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../../core/error/failures.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio dio;

  OrderRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
    try {
      final response = await dio.get('/api/orders');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final orders = data.map((json) => OrderModel.fromJson(json)).toList();
        return Right(orders);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to fetch orders'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await dio.put(
        '/api/orders/$orderId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: response.statusMessage ?? 'Failed to update status'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
