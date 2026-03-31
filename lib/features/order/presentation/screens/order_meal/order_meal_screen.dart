import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/user/presentation/providers/menu_provider.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

class OrderMealScreen extends ConsumerStatefulWidget {
  final MessModel? mess;
  final MenuItemModel? menuItem;
  
  const OrderMealScreen({super.key, this.mess, this.menuItem});

  @override
  ConsumerState<OrderMealScreen> createState() => _OrderMealScreenState();
}

class _OrderMealScreenState extends ConsumerState<OrderMealScreen> {
  int _quantity = 1;
  bool _autoOrder = false;

  @override
  Widget build(BuildContext context) {
    // 1. Resolve Mess and MenuItem IDs and objects from sources (Widget params, Navigator args, or URL)
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final Map<dynamic, dynamic>? args = arguments is Map ? arguments : null;
    
    // Check if we already have the full objects passed (ideal case when navigating from DishDetail)
    final MessModel? passedMess = widget.mess ?? (args?['mess'] is MessModel ? args!['mess'] as MessModel : null);
    final MenuItemModel? passedItem = widget.menuItem ?? (args?['item'] is MenuItemModel ? args!['item'] as MenuItemModel : null);

    String? messId = passedMess?.id;
    String? itemId = passedItem?.id;

    final String? routeName = ModalRoute.of(context)?.settings.name;
    // URL parsing if IDs are missing (direct browser navigation)
    if ((messId == null || itemId == null) && routeName != null) {
      // Handle both cases: /order-meal/... and order-meal/...
      final String prefix = routeName.startsWith('/') ? AppRoutes.orderMealPathPrefix : AppRoutes.orderMealPathPrefix.substring(1);
      
      if (routeName.startsWith(prefix)) {
        final segments = routeName.substring(prefix.length).split('/');
        if (segments.length >= 2) {
          messId = Uri.decodeComponent(segments[0]);
          itemId = Uri.decodeComponent(segments[1]);
        }
      }
    }

    // 2. Performance: If we already have the full objects, render directly
    if (passedMess != null && passedItem != null) {
      return _buildMainLayout(context, passedMess, passedItem);
    }

    // 3. Fallback: If we still don't have IDs at all, show "select meal" screen
    if (messId == null || itemId == null) {
      return _buildMainLayout(context, passedMess, passedItem);
    }

    // 4. Watch providers based on extracted IDs (Dynamic Loading)
    final messAsync = ref.watch(nearbyMessesProvider);
    final menuAsync = ref.watch(menuProvider(messId));

    // 5. Handle nested AsyncValue logic with a flattened return
    return messAsync.when(
      data: (messes) {
        MessModel? foundMess;
        try {
          foundMess = messes.firstWhere((m) => m.id == messId);
        } catch (_) {
          foundMess = passedMess;
        }
        
        if (foundMess == null) return _buildMainLayout(context, null, null);

        return menuAsync.when(
          data: (menu) {
            MenuItemModel? foundItem;
            if (menu != null && menu.items.isNotEmpty) {
              try {
                foundItem = menu.items.firstWhere((i) => i.id == itemId || i.name == itemId);
              } catch (_) {
                foundItem = passedItem;
              }
            } else {
              foundItem = passedItem;
            }
            return _buildMainLayout(context, foundMess!, foundItem);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text('Error loading menu: $e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error loading mess: $e'))),
    );
  }

  Widget _buildMainLayout(BuildContext context, MessModel? mess, MenuItemModel? menuItem) {
    if (mess == null || menuItem == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Confirm Order', style: TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please select a meal first', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (r) => false),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final double totalPrice = menuItem.price * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirm Order', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Availability warning banner
            if (!menuItem.isAvailable || menuItem.platesAvailable <= 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        menuItem.platesAvailable <= 0
                            ? 'This item is sold out and cannot be ordered.'
                            : 'This item is currently not available.',
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            _buildSummaryCard(mess, menuItem),
            const SizedBox(height: 24),
            _buildQuantitySection(),
            const SizedBox(height: 16),
            _buildAutoOrderSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(totalPrice, mess, menuItem),
    );
  }

  Widget _buildSummaryCard(MessModel mess, MenuItemModel menuItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: menuItem.image != null
                ? Image.network(
                    menuItem.image!,
                    width: 100, height: 100, fit: BoxFit.cover,
                    errorBuilder: (_, __, _e) => Container(
                      width: 100, height: 100, 
                      color: AppTheme.primaryLight,
                      child: const Icon(Icons.restaurant, color: AppTheme.primary, size: 40),
                    ),
                  )
                : Container(width: 100, height: 100, color: Colors.grey.shade100, child: const Icon(Icons.restaurant, size: 40)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menuItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(mess.name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 12),
              Text('₹${menuItem.price}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary), 
                onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary), 
                onPressed: () => setState(() => _quantity++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoOrderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: _autoOrder,
        onChanged: (v) => setState(() => _autoOrder = v),
        title: const Text('Daily Auto Order', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Automatically order this every day', style: TextStyle(fontSize: 12)),
        activeThumbColor: AppTheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildBottomBar(double total, MessModel mess, MenuItemModel menuItem) {
    final bool canCheckout = menuItem.isAvailable && menuItem.platesAvailable > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Payable', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('₹${total.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: canCheckout ? AppTheme.primary : Colors.grey)),
            ],
          )),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canCheckout ? AppTheme.primary : Colors.grey.shade300,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: canCheckout ? () {
                ref.read(cartProvider.notifier).clearCart();
                ref.read(cartProvider.notifier).addItem(menuItem, mess.id!, quantity: _quantity);

                Navigator.pushNamed(
                  context,
                  AppRoutes.orderSummaryPath(mess.id!),
                  arguments: mess,
                );
              } : null,
              child: Text(
                canCheckout ? 'Checkout' : 'Unavailable',
                style: TextStyle(
                  color: canCheckout ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
