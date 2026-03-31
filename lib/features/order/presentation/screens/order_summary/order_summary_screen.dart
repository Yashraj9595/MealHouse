import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';
import 'package:meal_house/features/profile/presentation/providers/profile_provider.dart';
import 'package:meal_house/features/user/presentation/providers/menu_provider.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

class OrderSummaryScreen extends ConsumerStatefulWidget {
  final MessModel? mess;

  const OrderSummaryScreen({super.key, this.mess});

  @override
  ConsumerState<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends ConsumerState<OrderSummaryScreen> {
  int _selectedPayment = 0; // 0=Wallet, 1=UPI, 2=Card
  static const double _platformFee = 5.0;
  Razorpay? _razorpay;
  MessModel? _pendingMess;

  Future<void>? _razorpayCheckoutScriptFuture;

  @override
  void initState() {
    super.initState();
    try {
      // Razorpay Flutter plugin is not available on Flutter Web in this project.
      // If we create/call it, web crashes with MissingPluginException and you get a white screen.
      if (!kIsWeb) {
        _razorpay = Razorpay();
        _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
        _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
        _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      }
    } catch (e) {
      debugPrint('Error initializing Razorpay: $e');
    }
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _verifyPayment(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String get _paymentMethodString {
    switch (_selectedPayment) {
      case 1: return 'UPI';
      case 2: return 'Card';
      default: return 'Wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // Resolve messId first
    String? messId = widget.mess?.id ?? (args is MessModel ? args.id : null);
    
    if (messId == null && routeName != null) {
      final String prefix = routeName.startsWith('/') ? AppRoutes.orderSummaryPathPrefix : AppRoutes.orderSummaryPathPrefix.substring(1);
      if (routeName.startsWith(prefix)) {
        final segments = routeName.substring(prefix.length).split('/');
        if (segments.isNotEmpty) {
          messId = segments[0];
        }
      }
    }

    // Attempt to get the MessModel
    if (messId != null && (widget.mess == null && args is! MessModel)) {
      final messAsync = ref.watch(nearbyMessesProvider);
      return messAsync.when(
        data: (messes) {
          MessModel? found;
          try {
            found = messes.firstWhere((m) => m.id == messId);
          } catch (_) {}
          
          if (found == null) return _buildErrorState('Mess not found');
          return _buildMainLayout(context, found);
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, s) => _buildErrorState('Error loading mess: $e'),
      );
    }

    final resolvedMess = widget.mess ?? (args is MessModel ? args : null);
    if (resolvedMess == null) return _buildErrorState('Invalid access');
    
    return _buildMainLayout(context, resolvedMess);
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(error, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.homeScreen),
              child: const Text('Go back Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainLayout(BuildContext context, MessModel mess) {
    final cartState = ref.watch(cartProvider);
    final orderState = ref.watch(orderActionProvider);
    final totalAmount = cartState.totalAmount + _platformFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: cartState.items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 10),
                  ...cartState.items.values.map((item) => _buildOrderCard(item, mess)),
                  const SizedBox(height: 12),
                  _buildPickupCard(
                    icon: Icons.location_on_rounded,
                    title: 'Pickup Point',
                    subtitle: mess.address,
                  ),
                  const SizedBox(height: 10),
                  _buildPickupCard(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Cuisine',
                    subtitle: mess.cuisineType,
                  ),
                  const SizedBox(height: 10),
                  _buildPickupCard(
                    icon: Icons.storefront_rounded,
                    title: 'Mess',
                    subtitle: mess.name,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment Method'),
                  const SizedBox(height: 10),
                  _buildWalletPaymentOption(),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    index: 1,
                    icon: Icons.account_balance_rounded,
                    title: 'UPI',
                    subtitle: 'GPay, PhonePe, Paytm',
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentOption(
                    index: 2,
                    icon: Icons.credit_card_rounded,
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa, Mastercard, Rupay',
                  ),
                  const SizedBox(height: 24),
                  _buildPriceBreakdown(cartState.totalAmount, _platformFee),
                ],
              ),
            ),
      bottomNavigationBar: _buildPlaceOrderButton(totalAmount, orderState.isLoading, mess),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
        ),
      ),
      title: Text(
        'Order Summary',
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.outfit(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Browse Menu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOrderCard(CartItem item, MessModel mess) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.item.image != null
                ? Image.network(
                    item.item.image!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _itemPlaceholder(),
                  )
                : _itemPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.item.name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  mess.name,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.item.price.toInt()} × ${item.quantity} = ₹${(item.item.price * item.quantity).toInt()}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Quantity stepper
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).removeItem(item.item.name),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).addItem(item.item, mess.id!),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey.shade200,
      child: const Icon(Icons.restaurant, color: Colors.grey),
    );
  }

  Widget _buildPickupCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletPaymentOption() {
    final isSelected = _selectedPayment == 0;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Wallet', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                Text('Pay using your meal wallet',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Radio<int>(
              value: 0,
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v!),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Radio<int>(
              value: index,
              groupValue: _selectedPayment,
              onChanged: (v) => setState(() => _selectedPayment = v!),
              activeColor: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(int subtotal, double fee) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _row('Items Subtotal', '₹$subtotal'),
          const SizedBox(height: 8),
          _row('Platform Fee', '₹${fee.toInt()}'),
          const Divider(height: 24),
          _row('Total Payable', '₹${(subtotal + fee).toInt()}', isTotal: true),
        ],
      ),
    );
  }

  Widget _row(String label, String val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(val,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTotal ? AppTheme.primary : Colors.black,
                fontSize: isTotal ? 18 : 14)),
      ],
    );
  }

  Widget _buildPlaceOrderButton(double total, bool isLoading, MessModel mess) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : () => _handlePlaceOrder(mess),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Place Order • ₹${total.toInt()}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(MessModel mess) async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) return;

    // Fetch current user to get userId
    final user = await ref.read(profileProvider.future);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please log in again to place an order'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    // Build order items from cart
    final items = cartState.items.values.map((cartItem) {
      return OrderItemModel(
        name: cartItem.item.name,
        quantity: cartItem.quantity,
        price: cartItem.item.price,
        mealType: cartItem.selectedMealType ?? (cartItem.item.mealType.isNotEmpty ? cartItem.item.mealType.first : 'Extra'),
      );
    }).toList();

    final order = OrderModel(
      userId: user.id,
      messId: mess.id!,
      items: items,
      totalPrice: cartState.totalAmount + _platformFee,
      paymentMethod: _paymentMethodString,
    );

    _pendingMess = mess;
    final success = await ref.read(orderActionProvider.notifier).placeOrder(order);

    if (!mounted) return;

    if (success) {
      final createdOrder = ref.read(orderActionProvider).createdOrder;
      if (createdOrder != null) {
        if (createdOrder.razorpayOrderId != null) {
          // Initiate payment (mobile uses razorpay_flutter, web uses Razorpay Checkout JS).
          _openRazorpayCheckout(createdOrder, user, mess);
        } else {
          // Wallet / non-razorpay orders.
          _onOrderSuccess(mess);
        }
      } else {
        // Defensive fallback
        _onOrderSuccess(mess);
      }
    } else {
      final error = ref.read(orderActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openRazorpayCheckout(OrderModel order, dynamic user, MessModel mess) {
    if (kIsWeb) {
      _openRazorpayWebCheckout(order, user, mess);
      return;
    }

    if (_razorpay == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment gateway is not available right now.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_SVyXIMniAQJ7bK', // Matches backend .env
      'amount': (order.totalPrice * 100).toInt(),
      'name': 'Meal House',
      'order_id': order.razorpayOrderId,
      'description': 'Order for ${mess.name}',
      'prefill': {
        'contact': user.mobile ?? '',
        'email': user.email ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      debugPrint('Opening Razorpay Checkout with Order ID: ${order.razorpayOrderId}');
      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Exception while opening Razorpay: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open payment gateway. Please try again or use another method.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadRazorpayCheckoutScript() async {
    if (_razorpayCheckoutScriptFuture != null) {
      return _razorpayCheckoutScriptFuture!;
    }

    final completer = Completer<void>();
    _razorpayCheckoutScriptFuture = completer.future;

    const scriptId = 'razorpay-checkout-js';
    final existing = html.document.getElementById(scriptId);
    if (existing != null) {
      completer.complete();
      return _razorpayCheckoutScriptFuture!;
    }

    final script = html.ScriptElement()
      ..id = scriptId
      ..src = 'https://checkout.razorpay.com/v1/checkout.js'
      ..async = true;

    script.onLoad.listen((_) {
      if (!completer.isCompleted) completer.complete();
    });
    script.onError.listen((_) {
      if (!completer.isCompleted) {
        completer.completeError('Failed to load Razorpay checkout script');
      }
    });

    html.document.head?.append(script);
    return _razorpayCheckoutScriptFuture!;
  }

  void _openRazorpayWebCheckout(OrderModel order, dynamic user, MessModel mess) async {
    if (!mounted) return;

    final razorpayOrderId = order.razorpayOrderId;
    if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing Razorpay order id for payment.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _loadRazorpayCheckoutScript();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load payment gateway. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Success callback from Razorpay Checkout JS.
    js_util.setProperty(html.window, '_mealhouseRazorpaySuccess', js_util.allowInterop((dynamic response) {
      () async {
        final paymentId = js_util.getProperty(response, 'razorpay_payment_id') as String?;
        final signature = js_util.getProperty(response, 'razorpay_signature') as String?;
        final returnedOrderId = js_util.getProperty(response, 'razorpay_order_id') as String?;

        if (!mounted) return;

        if (paymentId == null || signature == null || returnedOrderId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final verified = await ref.read(orderActionProvider.notifier).verifyRazorpayPayment(
              orderId: returnedOrderId,
              paymentId: paymentId,
              signature: signature,
            );

        if (!mounted) return;

        if (verified) {
          _onOrderSuccess(mess);
        } else {
          final error = ref.read(orderActionProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Payment verification failed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }();
    }));

    // Optional: dismiss callback.
    js_util.setProperty(html.window, '_mealhouseRazorpayDismiss', js_util.allowInterop(() {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled.'),
          backgroundColor: Colors.orange,
        ),
      );
    }));

    final options = {
      'key': 'rzp_test_SVyXIMniAQJ7bK',
      'amount': (order.totalPrice * 100).toInt(),
      'name': 'Meal House',
      'order_id': razorpayOrderId,
      'description': 'Order for ${mess.name}',
      'prefill': {
        'contact': user.mobile ?? '',
        'email': user.email ?? '',
      },
      'theme': {'color': '#e13742'},
    };

    final optionsJson = jsonEncode(options);

    // Using eval to build the JS function handler.
    js_util.callMethod(html.window, 'eval', ['''
      (function() {
        var options = $optionsJson;
        options.handler = function(response) {
          if (window._mealhouseRazorpaySuccess) {
            window._mealhouseRazorpaySuccess(response);
          }
        };
        options.modal = {
          ondismiss: function() {
            if (window._mealhouseRazorpayDismiss) {
              window._mealhouseRazorpayDismiss();
            }
          }
        };

        var rzp = new Razorpay(options);
        rzp.open();
      })();
    ''']);
  }

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    final success = await ref.read(orderActionProvider.notifier).verifyRazorpayPayment(
          orderId: response.orderId!,
          paymentId: response.paymentId!,
          signature: response.signature!,
        );

    if (success) {
      if (_pendingMess != null) {
        _onOrderSuccess(_pendingMess!);
      } else {
        // Fallback: This shouldn't happen if order was placed correctly
        final createdOrder = ref.read(orderActionProvider).createdOrder;
        // In verify, we might not have mess. Just go home if logic fails.
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (r) => false);
      }
    } else {
      if (mounted) {
        final error = ref.read(orderActionProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Payment verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onOrderSuccess(MessModel mess) {
    ref.read(cartProvider.notifier).clearCart();
    final createdOrder = ref.read(orderActionProvider).createdOrder;
    final orderId = createdOrder?.id;
    if (orderId == null || orderId.isEmpty) {
      // Fallback: go home if we don't have the order id.
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeScreen,
        (route) => false,
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderStatusPath(orderId),
      (route) => route.settings.name == AppRoutes.homeScreen,
      arguments: mess,
    );
  }
}
