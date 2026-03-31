import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

class OrderStatusScreen extends ConsumerStatefulWidget {
  final MessModel? mess;
  
  const OrderStatusScreen({super.key, this.mess});

  @override
  ConsumerState<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends ConsumerState<OrderStatusScreen> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _fadeController;
  late Animation<double> _checkScale;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _checkScale = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 200), () {
      _checkController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // 1. Resolve Order ID from URL if missing in provider
    String? orderId = ref.read(orderActionProvider).createdOrder?.id;
    if (orderId == null && routeName != null) {
      final String prefix = routeName.startsWith('/') ? AppRoutes.orderStatusPathPrefix : AppRoutes.orderStatusPathPrefix.substring(1);
      if (routeName.startsWith(prefix)) {
        orderId = routeName.substring(prefix.length).split('/')[0];
      }
    }

    // 2. Determine if we need to fetch the order and mess
    if (orderId != null && (widget.mess == null && args is! MessModel)) {
      final orderAsync = ref.watch(orderByIdProvider(orderId));
      
      return orderAsync.when(
        data: (order) {
          final messAsync = ref.watch(nearbyMessesProvider);
          return messAsync.when(
            data: (messes) {
              MessModel? foundMess;
              try {
                foundMess = messes.firstWhere((m) => m.id == order.messId);
              } catch (_) {}
              
              if (foundMess == null) return _buildErrorState('Mess not found for this order.');
              return _buildMainLayout(context, foundMess, order);
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, s) => _buildErrorState('Error loading mess: $e'),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, s) => _buildErrorState('Error loading order: $e'),
      );
    }

    // 3. Normal case (navigated from summary with args)
    final mess = widget.mess ?? (args is MessModel ? args : null);
    final order = ref.watch(orderActionProvider).createdOrder;

    if (mess == null) return _buildErrorState('No mess data available.');
    
    return _buildMainLayout(context, mess, order);
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (r) => false),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainLayout(BuildContext context, MessModel mess, OrderModel? order) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroImage(),
                    const SizedBox(height: 24),
                    _buildCheckmark(),
                    const SizedBox(height: 16),
                    FadeTransition(opacity: _fadeAnim, child: _buildConfirmationText(order?.id)),
                    const SizedBox(height: 24),
                    FadeTransition(opacity: _fadeAnim, child: _buildOrderDetailsCard(mess)),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, mess),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
          const Expanded(child: Text('Order Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_outlined, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text('Congratulations!', style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckmark() {
    return ScaleTransition(
      scale: _checkScale,
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(color: Colors.green.withAlpha(40), shape: BoxShape.circle),
        child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      ),
    );
  }

  Widget _buildConfirmationText(String? orderId) {
    return Column(
      children: [
        Text('Order Confirmed!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Your meal is being prepared 🍱', style: TextStyle(color: Colors.grey)),
        if (orderId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Order ID: ${orderId.substring(orderId.length > 8 ? orderId.length - 8 : 0).toUpperCase()}',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green.shade700),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderDetailsCard(MessModel mess) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          _buildDetailRow(Icons.storefront, 'MESS NAME', mess.name),
          const Divider(height: 24),
          _buildDetailRow(Icons.location_on, 'PICKUP POINT', mess.address),
          const Divider(height: 24),
          _buildDetailRow(Icons.access_time, 'CUISINE', mess.cuisineType),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, MessModel mess) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.trackOrderScreen,
                arguments: mess,
              );
            },
            child: const Text('Track Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              ref.read(orderActionProvider.notifier).reset();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (r) => false);
            },
            child: const Text('Go Home', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
