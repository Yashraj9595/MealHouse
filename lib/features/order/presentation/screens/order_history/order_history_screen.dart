import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';
import 'package:meal_house/core/router/app_routes.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Order History',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          bottom: TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            labelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'Completed'),
              Tab(text: 'Pending'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text('Failed to load orders', style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.refresh(myOrdersProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          data: (orders) {
            final completed = orders.where((o) => o.status == 'Delivered').toList();
            final pending = orders.where((o) => 
              o.status == 'Pending' || o.status == 'Confirmed' || o.status == 'Preparing' || o.status == 'OutForDelivery'
            ).toList();
            final cancelled = orders.where((o) => o.status == 'Cancelled').toList();

            return TabBarView(
              children: [
                _buildOrderList(context, completed, ref),
                _buildOrderList(context, pending, ref),
                _buildOrderList(context, cancelled, ref),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No orders here', style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => ref.refresh(myOrdersProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.green;
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return Colors.orange;
      case 'OutForDelivery': return Colors.purple;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final dateStr = order.orderDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate!.toLocal())
        : 'N/A';
    final shortId = order.id != null && order.id!.length >= 8
        ? '#${order.id!.substring(order.id!.length - 8).toUpperCase()}'
        : '#N/A';

    return GestureDetector(
      onTap: () {
        if (order.id != null) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderStatusPath(order.id!),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shortId,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (firstItem != null)
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.length == 1
                                ? firstItem.name
                                : '${firstItem.name} + ${order.items.length - 1} more',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            dateStr,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${order.totalPrice.toInt()}',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Divider(color: AppTheme.divider, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.payment_rounded, size: 14, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Paid via ${order.paymentMethod}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}