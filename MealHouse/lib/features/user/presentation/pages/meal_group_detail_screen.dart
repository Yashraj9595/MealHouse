import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:MealHouse/core/app_export.dart';
import 'package:MealHouse/core/di/injection.dart';
import 'package:MealHouse/routes/app_routes.dart';
import 'package:MealHouse/features/user/domain/repositories/user_repository.dart';
import 'package:MealHouse/features/user/data/models/meal_group_model.dart';
import 'package:MealHouse/shared/widgets/custom_image_widget.dart';
import 'package:MealHouse/core/theme/app_colors.dart';
import 'package:MealHouse/core/constants/app_icons.dart';
import 'package:MealHouse/shared/widgets/custom_icon_widget.dart';

class MealGroupDetailScreen extends StatefulWidget {
  final UserMealGroupModel mealGroup;

  const MealGroupDetailScreen({super.key, required this.mealGroup});

  @override
  State<MealGroupDetailScreen> createState() => _MealGroupDetailScreenState();
}

class _MealGroupDetailScreenState extends State<MealGroupDetailScreen> {
  int _quantity = 1;
  bool _isLoading = false;
  late Razorpay _razorpay;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final userRepo = getIt<UserRepository>();
      await userRepo.verifyRazorpayPayment({
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
        'orderId': _currentOrderId, // Our DB order ID
      });

      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed Successfully!'),
          content: const Text('Your payment has been verified and your order is confirmed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.userHomeScreen,
                  (route) => false,
                );
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification failed: $e')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  Future<void> _handleCheckout() async {
    if (widget.mealGroup.messId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Mess information is missing for this meal.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userRepo = getIt<UserRepository>();

      // 1. Create order in our backend
      final deliveryTime = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      
      _currentOrderId = await userRepo.placeOrder({
        'messId': widget.mealGroup.messId,
        'items': [
          {
            'mealGroupId': widget.mealGroup.id,
            'quantity': _quantity,
          }
        ],
        'deliveryTime': deliveryTime,
        // Using default user address & phone from backend fallback
      });

      // 2. Create Razorpay order from backend
      final razorpayOrderData = await userRepo.createRazorpayOrder(_currentOrderId!);

      // 3. Open Razorpay Checkout UI
      var options = {
        'key': razorpayOrderData['keyId'],
        'amount': razorpayOrderData['amount'], 
        'name': 'MealHouse',
        'description': 'Payment for ${widget.mealGroup.name}',
        'order_id': razorpayOrderData['id'], // Razorpay Order ID
        'timeout': 300, 
        'prefill': {
          'contact': '', // Will prompt user or fallback to razorpay saved details
          'email': ''
        }
      };

      _razorpay.open(options);

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.mealGroup.items;
    final mealType = widget.mealGroup.mealType;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 25.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.mealGroup.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const CustomImageWidget(
                        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const CustomIconWidget(iconName: AppIcons.back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(4.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${widget.mealGroup.price}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (mealType.isNotEmpty) ...[
                              SizedBox(height: 0.5.h),
                              _buildMealTypeBadge(mealType),
                            ],
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const CustomIconWidget(
                                iconName: AppIcons.clock,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '20-30 min',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'What\'s inside',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.h),
                    ...items.map((it) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 0.8.h),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (it.description != null)
                                    Text(
                                      it.description!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textBody,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 10.h),
                  ]),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppColors.primary),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Pay Now (₹${widget.mealGroup.price * _quantity})'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeBadge(String type) {
    Color color;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'breakfast':
        color = Colors.orange;
        icon = Icons.wb_sunny_outlined;
        break;
      case 'lunch':
        color = Colors.blue;
        icon = Icons.light_mode_outlined;
        break;
      case 'dinner':
        color = Colors.indigo;
        icon = Icons.nights_stay_outlined;
        break;
      default:
        color = Colors.grey;
        icon = Icons.restaurant_menu;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 1.w),
          Text(
            type,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
