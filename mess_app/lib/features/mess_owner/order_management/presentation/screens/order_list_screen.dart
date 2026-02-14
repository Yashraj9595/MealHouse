import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:sizer/sizer.dart';
import '../state/order_providers.dart';
import '../widgets/order_card_widget.dart';
import '../widgets/order_detail_bottom_sheet.dart';
import '../widgets/order_filter_chip_widget.dart';
import 'package:MealHouse/features/mess_owner/order_management/domain/entities/order_entity.dart';

/// Order Management Screen for Mess Owners
/// Centralizes incoming order processing and status management
class OrderListScreen extends ConsumerStatefulWidget {
  const OrderListScreen({super.key});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedOrders = {};
  bool _isBulkSelectionMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(ordersListProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orders refreshed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleOrderAction(String orderId, String action) async {
    HapticFeedback.lightImpact();

    String status = '';
    switch (action) {
      case 'accept':
        status = 'confirmed'; // Mapping to backend status
        break;
      case 'reject':
        status = 'cancelled';
        break;
      case 'ready':
        status = 'ready';
        break;
      case 'delivered':
        status = 'delivered';
        break;
      default:
        return;
    }

    // Optimistic update or show loading could be better, but simple await for now
    try {
      final updateUseCase = ref.read(updateOrderStatusUseCaseProvider);
      final result = await updateUseCase(orderId, status);
      
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order ${action == 'reject' ? 'rejected' : 'updated'} successfully'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          // Refresh list to show updated status
          ref.invalidate(ordersListProvider);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showOrderDetails(OrderEntity order) {
    HapticFeedback.lightImpact();
    // Convert Entity to Map for the existing BottomSheet widget if needed, 
    // or better, verify if BottomSheet expects Entity or Map. 
    // The previous code passed a Map. Let's check OrderDetailBottomSheet but 
    // for now I will pass a map constructed from entity to minimize friction 
    // if I don't want to refactor the bottom sheet right now.
    // Ideally, BottomSheet should take Entity.
    
    // Constructing a map similar to what mock data provided, as existing widgets might rely on it.
    // However, clean architecture says widgets should use Entities. 
    // I previously saw OrderDetailBottomSheet import. I didn't read it.
    // I will assume it accepts Map for now based on previous usage, 
    // and construct it. 
    
    final orderMap = {
      "id": order.id,
      "orderTime": order.orderTime,
      "customerName": order.customerName,
      "customerPhone": order.customerPhone,
      "items": order.items,
      "totalAmount": order.price,
      "status": order.status.name.capitalize(),
      "specialInstructions": order.specialInstructions ?? "",
      "orderHistory": [], // History not in entity yet
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: OrderDetailBottomSheet(
            order: orderMap, 
            onAction: _handleOrderAction
          ),
        ),
      ),
    );
  }

  void _toggleBulkSelection() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isBulkSelectionMode = !_isBulkSelectionMode;
      if (!_isBulkSelectionMode) {
        _selectedOrders.clear();
      }
    });
  }

  Future<void> _handleBulkAction(String action) async {
    if (_selectedOrders.isEmpty) return;

    HapticFeedback.mediumImpact();

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Action'),
        content: Text(
          'Apply "$action" to ${_selectedOrders.length} selected orders?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final orderId in _selectedOrders) {
        await _handleOrderAction(orderId, action.toLowerCase());
      }
      setState(() {
        _selectedOrders.clear();
        _isBulkSelectionMode = false;
      });
    }
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    List<OrderEntity> filtered = List.from(orders);

    // Filter by Status
    if (_selectedFilter != 'All') {
      filtered = filtered.where((order) {

        // Map UI filter to Enum name
        switch (_selectedFilter) {
          case 'Pending': return order.status == OrderStatus.pending;
          case 'Confirmed': return order.status == OrderStatus.preparing; // 'confirmed' maps to 'preparing' in model for now or need adjustment
          case 'Ready': return order.status == OrderStatus.ready;
          case 'Delivered': return order.status == OrderStatus.delivered;
          default: return true;
        }
      }).toList();
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final name = order.customerName.toLowerCase();
        final id = order.id.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    }

    // Sort by time descending
    filtered.sort((a, b) => b.orderTime.compareTo(a.orderTime));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const CustomIconWidget(iconName: AppIcons.back, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Order Management',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const CustomIconWidget(
              iconName: AppIcons.filter,
              color: AppColors.textHeader,
              size: 24,
            ),
            onPressed: () {},
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.onSurface, size: 24),
            onPressed: () => ref.invalidate(ordersListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: ordersAsync.when(
          data: (orders) {
            final filteredOrders = _filterOrders(orders);
            final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
            // Rough estimation
            final preparingCount = orders.where((o) => o.status == OrderStatus.preparing).length;
 

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter & Search Section
                 Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search by customer name or order ID.',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(1.5.h),
                              child: const CustomIconWidget(
                                iconName: AppIcons.search,
                                color: AppColors.textBody,
                                size: 20,
                              ),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const CustomIconWidget(
                                      iconName: AppIcons.close,
                                      color: AppColors.textBody,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        height: 5.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            OrderFilterChipWidget(
                              label: 'All',
                              count: orders.length,
                              isSelected: _selectedFilter == 'All',
                              onTap: () => setState(() => _selectedFilter = 'All'),
                            ),
                            SizedBox(width: 2.w),
                            OrderFilterChipWidget(
                              label: 'Pending',
                              count: pendingCount,
                              isSelected: _selectedFilter == 'Pending',
                              onTap: () => setState(() => _selectedFilter = 'Pending'),
                            ),
                            SizedBox(width: 2.w),
                            OrderFilterChipWidget(
                              label: 'Confirmed',
                              count: preparingCount,
                              isSelected: _selectedFilter == 'Confirmed',
                              onTap: () => setState(() => _selectedFilter = 'Confirmed'),
                            ),
                            SizedBox(width: 2.w),
                            OrderFilterChipWidget(
                              label: 'Ready',
                              count: orders.where((o) => o.status == OrderStatus.ready).length,
                              isSelected: _selectedFilter == 'Ready',
                              onTap: () => setState(() => _selectedFilter = 'Ready'),
                            ),
                            SizedBox(width: 2.w),
                            OrderFilterChipWidget(
                              label: 'Delivered',
                              count: orders.where((o) => o.status == OrderStatus.delivered).length,
                              isSelected: _selectedFilter == 'Delivered',
                              onTap: () => setState(() => _selectedFilter = 'Delivered'),
                            ),
                          ],
                        ),
                      ),
                      if (_isBulkSelectionMode && _selectedOrders.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${_selectedOrders.length} selected',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => _handleBulkAction('Confirmed'),
                                child: const Text('Accept All'),
                              ),
                              TextButton(
                                onPressed: () => _handleBulkAction('Ready'),
                                child: const Text('Mark Ready'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: AppIcons.orders,
                                color: AppColors.textBody.withValues(alpha: 0.3),
                                size: 64,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No orders found'
                                    : 'No orders yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.textBody.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _handleRefresh,
                          color: AppColors.primary,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 20.h), // Extra padding for bottom bar
                            itemCount: filteredOrders.length,
                            separatorBuilder: (context, index) => SizedBox(height: 2.h),
                            itemBuilder: (context, index) {
                              final order = filteredOrders[index];
                              final isSelected = _selectedOrders.contains(order.id);
                              
                              return OrderCardWidget(
                                order: order,
                                orderItems: order.items,
                                isSelected: isSelected,
                                isBulkSelectionMode: _isBulkSelectionMode,
                                onTap: () {
                                  if (_isBulkSelectionMode) {
                                    setState(() {
                                      isSelected
                                          ? _selectedOrders.remove(order.id)
                                          : _selectedOrders.add(order.id);
                                    });
                                  } else {
                                    _showOrderDetails(order);
                                  }
                                },
                                onLongPress: () {
                                  if (!_isBulkSelectionMode) {
                                    _toggleBulkSelection();
                                    setState(() => _selectedOrders.add(order.id));
                                  }
                                },
                                onAccept: () => _handleOrderAction(order.id, 'accept'),
                                onReject: () => _handleOrderAction(order.id, 'reject'),
                                onMarkReady: () => _handleOrderAction(order.id, 'ready'),
                                onMarkDelivered: () => _handleOrderAction(order.id, 'delivered'),
                                onCall: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${order.customerPhone}...')),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 2.h),
                Text('Error loading orders: $err'),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => ref.invalidate(ordersListProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      // Only show bottom bar when data is loaded (or handle usage of async data)
      // For simplicity, we can hide it or show simplified version during loading
      bottomNavigationBar: ordersAsync.isLoading || ordersAsync.hasError 
          ? null 
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Orders',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textBody.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${ordersAsync.value?.where((o) => o.status == OrderStatus.pending).length ?? 0}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Est. Prep Time',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textBody.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${(ordersAsync.value?.where((o) => o.status == OrderStatus.preparing).length ?? 0) * 15} min',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
