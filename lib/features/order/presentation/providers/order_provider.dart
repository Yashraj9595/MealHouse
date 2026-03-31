import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/domain/repositories/order_repository.dart';

// ─── My Orders list ─────────────────────────────────────────────────────────
final myOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final repository = sl<OrderRepository>();
  return await repository.getMyOrders();
});

final orderByIdProvider = FutureProvider.autoDispose.family<OrderModel, String>((ref, orderId) async {
  final repository = sl<OrderRepository>();
  return await repository.getOrderById(orderId);
});

// ─── Place Order state machine ────────────────────────────────────────────────
class PlaceOrderState {
  final bool isLoading;
  final OrderModel? createdOrder;
  final String? error;

  const PlaceOrderState({
    this.isLoading = false,
    this.createdOrder,
    this.error,
  });

  PlaceOrderState copyWith({
    bool? isLoading,
    OrderModel? createdOrder,
    String? error,
  }) =>
      PlaceOrderState(
        isLoading: isLoading ?? this.isLoading,
        createdOrder: createdOrder ?? this.createdOrder,
        error: error ?? this.error,
      );
}

class OrderNotifier extends Notifier<PlaceOrderState> {
  @override
  PlaceOrderState build() => const PlaceOrderState();

  Future<bool> placeOrder(OrderModel order) async {
    state = const PlaceOrderState(isLoading: true);
    try {
      final repository = sl<OrderRepository>();
      final created = await repository.createOrder(order);
      state = PlaceOrderState(createdOrder: created);
      return true;
    } catch (e) {
      state = PlaceOrderState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    state = const PlaceOrderState(isLoading: true);
    try {
      final repository = sl<OrderRepository>();
      await repository.updateOrderStatus(orderId, status);
      state = const PlaceOrderState(); // Reset or success state
      return true;
    } catch (e) {
      state = PlaceOrderState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    state = const PlaceOrderState(isLoading: true);
    try {
      final repository = sl<OrderRepository>();
      final updated = await repository.verifyPayment(orderId, paymentId, signature);
      state = PlaceOrderState(createdOrder: updated);
      return true;
    } catch (e) {
      state = PlaceOrderState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> fetchOrderById(String orderId) async {
    state = const PlaceOrderState(isLoading: true);
    try {
      final repository = sl<OrderRepository>();
      final order = await repository.getOrderById(orderId);
      state = PlaceOrderState(createdOrder: order);
      return true;
    } catch (e) {
      state = PlaceOrderState(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void reset() {
    state = const PlaceOrderState();
  }
}

final orderActionProvider =
    NotifierProvider<OrderNotifier, PlaceOrderState>(OrderNotifier.new);
