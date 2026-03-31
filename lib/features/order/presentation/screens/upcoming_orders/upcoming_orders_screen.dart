import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';

class UpcomingOrdersScreen extends ConsumerWidget {
  const UpcomingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upcoming Orders',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text('Failed to load upcoming orders',
                  style: GoogleFonts.dmSans(color: AppTheme.textSecondary)),
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
          // Upcoming = non-delivered, non-cancelled
          final upcoming = orders
              .where((o) =>
                  o.status == 'Pending' ||
                  o.status == 'Confirmed' ||
                  o.status == 'Preparing' ||
                  o.status == 'OutForDelivery')
              .toList();

          if (upcoming.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => ref.refresh(myOrdersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: upcoming.length,
              itemBuilder: (context, i) =>
                  _UpcomingOrderCard(order: upcoming[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule_rounded, size: 72, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Orders',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your active orders will appear here',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.homeScreen, (r) => false),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            label: const Text('Browse Meals', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingOrderCard extends StatelessWidget {
  final OrderModel order;

  const _UpcomingOrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed': return Colors.blue;
      case 'Preparing': return Colors.orange;
      case 'OutForDelivery': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Confirmed': return Icons.check_circle_outline;
      case 'Preparing': return Icons.soup_kitchen_rounded;
      case 'OutForDelivery': return Icons.delivery_dining;
      default: return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final dateStr = order.orderDate != null
        ? DateFormat('dd MMM yyyy  •  hh:mm a').format(order.orderDate!.toLocal())
        : '';
    final shortId = order.id != null && order.id!.length >= 8
        ? '#${order.id!.substring(order.id!.length - 8).toUpperCase()}'
        : '#N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(order.status),
                    color: _statusColor(order.status), size: 18),
                const SizedBox(width: 8),
                Text(
                  order.status.toUpperCase().replaceAll('OUTFORDELIVERY', 'OUT FOR DELIVERY'),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(order.status),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  shortId,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main item info
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.restaurant_menu, color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstItem != null
                                ? (order.items.length == 1
                                    ? firstItem.name
                                    : '${firstItem.name} + ${order.items.length - 1} more')
                                : 'Order',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.cancelOrderScreen,
                            arguments: order,
                          );
                        },
                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Track order doesn't need a mess here — use order ID approach
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tracking coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                        label: Text(
                          'Track Order',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}