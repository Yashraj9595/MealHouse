import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:MealHouse/core/app_export.dart';

class PlaceOrderScreen extends ConsumerStatefulWidget {
  final String messId;
  final String messName;
  final String messImage;
  final List<Map<String, dynamic>> menuItems;

  const PlaceOrderScreen({
    super.key,
    required this.messId,
    required this.messName,
    required this.messImage,
    required this.menuItems,
  });

  @override
  ConsumerState<PlaceOrderScreen> createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends ConsumerState<PlaceOrderScreen> {
  final Map<String, int> _quantities = {};
  final TextEditingController _specialInstructionsController = TextEditingController();
  String _selectedDeliveryType = 'delivery';
  String _selectedPaymentMethod = 'cod';
  DateTime? _selectedDeliveryTime;

  @override
  void initState() {
    super.initState();
    // Initialize quantities to 0 for all items
    for (final item in widget.menuItems) {
      _quantities[item['id']] = 0;
    }
  }

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    double total = 0;
    for (final item in widget.menuItems) {
      final quantity = _quantities[item['id']] ?? 0;
      total += (item['price'] as double) * quantity;
    }
    return total;
  }

  int get _totalItems {
    return _quantities.values.fold(0, (sum, qty) => sum + qty);
  }

  bool get _hasItems => _totalItems > 0;

  void _updateQuantity(String itemId, int delta) {
    setState(() {
      final currentQty = _quantities[itemId] ?? 0;
      final newQty = (currentQty + delta).clamp(0, 99);
      _quantities[itemId] = newQty;
    });
  }

  void _selectDeliveryTime(BuildContext context) async {
    final now = DateTime.now();
    final selectedTime = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
    );

    if (selectedTime != null) {
      final selectedTimeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      );

      if (selectedTimeOfDay != null) {
        setState(() {
          _selectedDeliveryTime = DateTime(
            selectedTime.year,
            selectedTime.month,
            selectedTime.day,
            selectedTimeOfDay.hour,
            selectedTimeOfDay.minute,
          );
        });
      }
    }
  }

  void _placeOrder() {
    if (!_hasItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items to your order'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDeliveryTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select delivery time'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show order confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Items: $_totalItems'),
            Text('Total Amount: ₹${_totalAmount.toStringAsFixed(0)}'),
            Text('Delivery Time: ${DateFormat('dd MMM yyyy • hh:mm a').format(_selectedDeliveryTime!)}'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to place this order?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe13742),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _processOrder() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFe13742)),
      ),
    );

    // Simulate order processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Remove loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xff257e3e),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Order Placed!'),
            ],
          ),
          content: const Text(
            'Your order has been successfully placed. You will receive a confirmation shortly.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to orders screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe13742),
              ),
              child: const Text(
                'View Orders',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fb),
      appBar: AppBar(
        backgroundColor: const Color(0xFFe13742),
        elevation: 0,
        title: Text(
          'Place Order',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Mess Info Header
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFe13742).withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: widget.messImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.messName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Select items for your order',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xff586377),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(4.w),
              itemCount: widget.menuItems.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final item = widget.menuItems[index];
                final quantity = _quantities[item['id']] ?? 0;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Row(
                      children: [
                        // Item Image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xfff5f6fb),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item['image'] != null
                                ? CustomImageWidget(
                                    imageUrl: item['image'],
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.restaurant,
                                    color: Color(0xff586377),
                                  ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        
                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                item['description'] as String? ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xff586377),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                '₹${(item['price'] as double).toStringAsFixed(0)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFFe13742),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Quantity Controls
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xfff5f6fb),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _updateQuantity(item['id'], -1),
                                icon: const Icon(Icons.remove, size: 20),
                                color: quantity > 0 ? const Color(0xFFe13742) : Colors.grey,
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '$quantity',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _updateQuantity(item['id'], 1),
                                icon: const Icon(Icons.add, size: 20),
                                color: const Color(0xFFe13742),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Order Summary and Checkout
          if (_hasItems)
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Delivery Options
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDeliveryType = 'delivery'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: _selectedDeliveryType == 'delivery'
                                  ? const Color(0xFFe13742).withValues(alpha: 0.1)
                                  : const Color(0xfff5f6fb),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDeliveryType == 'delivery'
                                    ? const Color(0xFFe13742)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delivery_dining,
                                  color: _selectedDeliveryType == 'delivery'
                                      ? const Color(0xFFe13742)
                                      : const Color(0xff586377),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Delivery',
                                  style: TextStyle(
                                    color: _selectedDeliveryType == 'delivery'
                                        ? const Color(0xFFe13742)
                                        : const Color(0xff586377),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedDeliveryType = 'pickup'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: _selectedDeliveryType == 'pickup'
                                  ? const Color(0xFFe13742).withValues(alpha: 0.1)
                                  : const Color(0xfff5f6fb),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDeliveryType == 'pickup'
                                    ? const Color(0xFFe13742)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store,
                                  color: _selectedDeliveryType == 'pickup'
                                      ? const Color(0xFFe13742)
                                      : const Color(0xff586377),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Pickup',
                                  style: TextStyle(
                                    color: _selectedDeliveryType == 'pickup'
                                        ? const Color(0xFFe13742)
                                        : const Color(0xff586377),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Delivery Time Selection
                  GestureDetector(
                    onTap: () => _selectDeliveryTime(context),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f6fb),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Color(0xff586377)),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Delivery Time',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: const Color(0xff586377),
                                  ),
                                ),
                                Text(
                                  _selectedDeliveryTime != null
                                      ? DateFormat('dd MMM yyyy • hh:mm a').format(_selectedDeliveryTime!)
                                      : 'Select delivery time',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedDeliveryTime != null
                                        ? Colors.black
                                        : const Color(0xff586377),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xff586377)),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Special Instructions
                  TextField(
                    controller: _specialInstructionsController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Special instructions (optional)',
                      hintStyle: TextStyle(color: const Color(0xff586377).withValues(alpha: 0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xffe6e9ef)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFe13742)),
                      ),
                      contentPadding: EdgeInsets.all(3.w),
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Total and Place Order Button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xff586377),
                              ),
                            ),
                            Text(
                              '₹${_totalAmount.toStringAsFixed(0)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFe13742),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe13742),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Place Order',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
