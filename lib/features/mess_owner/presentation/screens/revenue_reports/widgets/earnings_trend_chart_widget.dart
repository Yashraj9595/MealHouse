import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:intl/intl.dart';

class EarningsTrendChartWidget extends StatefulWidget {
  final int selectedPeriodIndex;
  final double dailyAvg;
  final List<OrderModel> orders;

  const EarningsTrendChartWidget({
    super.key,
    required this.selectedPeriodIndex,
    required this.dailyAvg,
    required this.orders,
  });

  @override
  State<EarningsTrendChartWidget> createState() =>
      _EarningsTrendChartWidgetState();
}

class _EarningsTrendChartWidgetState extends State<EarningsTrendChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _barAnimation;
  int? _touchedIndex;

  final List<Map<String, dynamic>> _chartData = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _barAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _calculateChartData();
  }

  void _calculateChartData() {
    _chartData.clear();
    if (widget.orders.isEmpty) {
      _animController.forward();
      return;
    }

    final Map<String, double> aggregatedData = {};
    for (var order in widget.orders) {
      if (order.orderDate == null) continue;
      String key;
      if (widget.selectedPeriodIndex == 0) {
        // Today => Group by hour
        key = DateFormat('ha').format(order.orderDate!).toLowerCase();
      } else if (widget.selectedPeriodIndex == 1) {
        // 7 days => Group by short weekday
        key = DateFormat('E').format(order.orderDate!);
      } else {
        // 30 days => Group by day
        key = DateFormat('d MMM').format(order.orderDate!);
      }
      aggregatedData[key] = (aggregatedData[key] ?? 0.0) + order.totalPrice;
    }

    // Now format into list of maps
    double maxVal = 0;
    aggregatedData.forEach((key, value) {
      if (value > maxVal) maxVal = value;
    });

    // To ensure order, we sort the entries by original orderDate or just use the keys depending on period length
    // For simplicity, let's just map them.
    for (var entry in aggregatedData.entries) {
      _chartData.add({
        'label': entry.key,
        'value': entry.value,
        'highlight': entry.value == maxVal && maxVal > 0,
      });
    }

    // If empty or small, pad it?
    if (_chartData.isEmpty) {
       _chartData.add({'label': '-', 'value': 0.0, 'highlight': false});
    }

    _animController.reset();
    _animController.forward();
    _touchedIndex = null;
  }

  @override
  void didUpdateWidget(EarningsTrendChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriodIndex != widget.selectedPeriodIndex ||
        oldWidget.orders != widget.orders) {
      _calculateChartData();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatAvg(double value) {
    if (value >= 1000) {
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
    final data = _chartData;
    final maxValue = data.isEmpty
        ? 0.0
        : data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);

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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings Trend',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Daily Avg: ${_formatAvg(widget.dailyAvg)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceBetween,
                    maxY: maxValue * 1.25,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppTheme.textPrimary,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final value = rod.toY;
                          String formatted;
                          if (value >= 1000) {
                            final s = value.toStringAsFixed(0);
                            formatted = s.length > 3
                                ? '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}'
                                : '₹$s';
                          } else {
                            formatted = '₹${value.toStringAsFixed(0)}';
                          }
                          return BarTooltipItem(
                            formatted,
                            GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      touchCallback: (event, response) {
                        // TODO: Replace with Riverpod/Bloc for production
                        setState(() {
                          if (response?.spot != null &&
                              event is! FlPointerExitEvent) {
                            _touchedIndex =
                                response!.spot!.touchedBarGroupIndex;
                          } else {
                            _touchedIndex = null;
                          }
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
                            final label = data[index]['label'] as String;
                            if (label.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.divider,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(data.length, (index) {
                      final item = data[index];
                      final isHighlight = item['highlight'] as bool;
                      final isTouched = _touchedIndex == index;
                      final rawValue = item['value'] as double;
                      final animatedValue = rawValue * _barAnimation.value;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: animatedValue,
                            width: data.length > 20 ? 6 : 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            color: isTouched
                                ? AppTheme.primary
                                : isHighlight
                                ? AppTheme.primary
                                : AppTheme.primaryContainer,
                          ),
                        ],
                      );
                    }),
                  ),
                  swapAnimationDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}