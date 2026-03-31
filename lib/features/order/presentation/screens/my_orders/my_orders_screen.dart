import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          title: Text(
            'My Orders',
            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            labelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (orders) {
            final active = orders.where((o) => o.status == 'Confirmed' || o.status == 'Preparing' || o.status == 'OutForDelivery').toList();
            final upcoming = orders.where((o) => o.status == 'Pending').toList();
            final history = orders.where((o) => o.status == 'Delivered').toList();
            final cancelled = orders.where((o) => o.status == 'Cancelled').toList();

            return TabBarView(
              children: [
                _buildOrderList(context, active, ref, 'active'),
                _buildOrderList(context, upcoming, ref, 'upcoming'),
                _buildOrderList(context, history, ref, 'history'),
                _buildOrderList(context, cancelled, ref, 'cancelled'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, WidgetRef ref, String type) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No $type orders found', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(myOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return Colors.orange;
      case 'OutForDelivery': return Colors.purple;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItemName = order.items.isNotEmpty ? order.items.first.name : 'Unknown Dish';
    final dateStr = order.orderDate != null
        ? DateFormat('dd MMM, hh:mm a').format(order.orderDate!.toLocal())
        : 'N/A';
        
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id?.substring(order.id!.length - 6).toUpperCase() ?? "N/A"}', 
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.toUpperCase(), 
                  style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                width: 50, height: 50, 
                decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)), 
                child: const Icon(Icons.restaurant_menu, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  order.items.length > 1 ? '$firstItemName + ${order.items.length - 1} items' : firstItemName, 
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ])),
              Text('₹${order.totalPrice.toInt()}', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.primary)),
            ],
          ),
          if (order.status != 'Delivered' && order.status != 'Cancelled') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cancelOrderScreen, arguments: order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (order.id != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.orderStatusPath(order.id!),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Track', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
