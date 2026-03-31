import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final List<OrderModel> orders;

  const PaymentMethodsWidget({super.key, required this.orders});

  @override
  State<PaymentMethodsWidget> createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;

  List<Map<String, dynamic>> _paymentData = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _calculatePaymentData();
  }

  void _calculatePaymentData() {
    final Map<String, double> map = {};
    double total = 0.0;
    for (var order in widget.orders) {
      final method = order.paymentMethod.isNotEmpty ? order.paymentMethod : 'Unknown';
      map[method] = (map[method] ?? 0.0) + order.totalPrice;
      total += order.totalPrice;
    }

    final list = map.entries.map((e) {
      final pct = total > 0 ? e.value / total : 0.0;
      return {
        'method': e.key,
        'amount': e.value,
        'percent': (pct * 100).round(),
        'fraction': pct,
      };
    }).toList();

    list.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    _paymentData = list;
    
    _animController.reset();
    _animController.forward();
  }

  @override
  void didUpdateWidget(PaymentMethodsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _calculatePaymentData();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
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
    final data = _paymentData;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Methods',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            Text(
              'No data for the selected period.',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          else
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                children: List.generate(data.length, (index) {
                  final item = data[index];
                  final isLast = index == data.length - 1;
                  return Column(
                    children: [
                      _PaymentMethodRow(
                        method: item['method'] as String,
                        amount: _formatAmount(item['amount'] as double),
                        percent: item['percent'] as int,
                        fraction:
                            (item['fraction'] as double) *
                            _progressAnimation.value,
                      ),
                      if (!isLast) const SizedBox(height: 16),
                    ],
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final String method;
  final String amount;
  final int percent;
  final double fraction;

  const _PaymentMethodRow({
    required this.method,
    required this.amount,
    required this.percent,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              method,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '$amount ($percent%)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Progress bar
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
