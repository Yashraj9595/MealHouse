import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';

class TopSellingThalisWidget extends StatefulWidget {
  final List<OrderModel> orders;
  final bool isTablet;

  const TopSellingThalisWidget({
    super.key,
    required this.orders,
    this.isTablet = false,
  });

  @override
  State<TopSellingThalisWidget> createState() => _TopSellingThalisWidgetState();
}

class _TopSellingThalisWidgetState extends State<TopSellingThalisWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final List<Animation<double>> _itemAnimations = [];

  List<Map<String, dynamic>> _scaledThalis = [];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _calculateThalis();
  }

  void _calculateThalis() {
    final Map<String, Map<String, dynamic>> map = {};
    for (var order in widget.orders) {
      for (var item in order.items) {
        if (!map.containsKey(item.name)) {
          map[item.name] = {
            'name': item.name,
            'orders': 0,
            'revenue': 0.0,
            'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
            'semanticLabel': item.name,
          };
        }
        map[item.name]!['orders'] = (map[item.name]!['orders'] as int) + item.quantity;
        map[item.name]!['revenue'] = (map[item.name]!['revenue'] as double) + (item.price * item.quantity);
      }
    }

    final list = map.values.toList();
    list.sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
    
    _scaledThalis = list.take(5).toList();
    _buildItemAnimations();
    _staggerController.reset();
    _staggerController.forward();
  }

  void _buildItemAnimations() {
    _itemAnimations.clear();
    for (int i = 0; i < _scaledThalis.length; i++) {
      final start = (i * 0.15).clamp(0.0, 0.7);
      final end = (start + 0.4).clamp(0.0, 1.0);
      _itemAnimations.add(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(TopSellingThalisWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _calculateThalis();
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  String _formatRevenue(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    } else if (value >= 1000) {
      final s = value.toStringAsFixed(0);
      if (s.length > 3) {
        return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
      }
      return '₹$s';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final thalis = _scaledThalis;

    if (thalis.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No orders within this period.',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
        ),
      );
    }

    if (widget.isTablet) {
      // 2-column grid on tablet
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.2,
        ),
        itemCount: thalis.length,
        itemBuilder: (context, index) {
          if (index >= _itemAnimations.length) return const SizedBox.shrink();
          return FadeTransition(
            opacity: _itemAnimations[index],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(_itemAnimations[index]),
              child: _ThaliCard(
                thali: thalis[index],
                formattedRevenue: _formatRevenue(
                  thalis[index]['revenue'] as double,
                ),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: List.generate(thalis.length, (index) {
        if (index >= _itemAnimations.length) return const SizedBox.shrink();
        return FadeTransition(
          opacity: _itemAnimations[index],
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(_itemAnimations[index]),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: index == thalis.length - 1 ? 0 : 10,
              ),
              child: _ThaliCard(
                thali: thalis[index],
                formattedRevenue: _formatRevenue(
                  thalis[index]['revenue'] as double,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ThaliCard extends StatelessWidget {
  final Map<String, dynamic> thali;
  final String formattedRevenue;

  const _ThaliCard({required this.thali, required this.formattedRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: thali['imageUrl'] as String,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              semanticLabel: thali['semanticLabel'] as String,
            ),
          ),
          const SizedBox(width: 12),
          // Name + orders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  thali['name'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${thali['orders']} orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Revenue
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedRevenue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Total Revenue',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
