import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/order/domain/models/order_model.dart';
import 'package:meal_house/features/order/presentation/providers/order_provider.dart';

class CancelOrderScreen extends ConsumerStatefulWidget {
  final OrderModel order;
  const CancelOrderScreen({super.key, required this.order});

  @override
  ConsumerState<CancelOrderScreen> createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends ConsumerState<CancelOrderScreen> {
  int? _selectedReason;
  final TextEditingController _moreInfoController = TextEditingController();

  final List<String> _reasons = [
    'Ordered by mistake',
    'Change of plans',
    'Ordered from wrong mess',
    'Pickup point too far',
    'Other',
  ];

  @override
  void dispose() {
    _moreInfoController.dispose();
    super.dispose();
  }

  Future<void> _handleCancellation() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    final success = await ref
        .read(orderActionProvider.notifier)
        .updateStatus(widget.order.id!, 'Cancelled');

    if (!mounted) return;

    if (success) {
      ref.refresh(myOrdersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(orderActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to cancel order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(orderActionProvider).isLoading;
    final firstItem = widget.order.items.isNotEmpty ? widget.order.items.first : null;
    final dateStr = widget.order.orderDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(widget.order.orderDate!.toLocal())
        : 'N/A';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cancel Order',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummarySection(firstItem, dateStr),
                  const SizedBox(height: 20),
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _buildReasonSection(),
                  const SizedBox(height: 16),
                  if (_selectedReason == 4) _buildMoreInfoField(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, isLoading),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderItemModel? item, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Order Summary',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item?.name ?? 'Order',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Total Amount',
          '₹${widget.order.totalPrice.toInt()}',
          isLabelMuted: true,
          labelBold: true,
          valueColor: AppTheme.primary,
          valueBold: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLabelMuted = false,
    bool labelBold = false,
    bool valueBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: labelBold ? FontWeight.w600 : FontWeight.w400,
            color: isLabelMuted ? const Color(0xFF8A8A8A) : Colors.black,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD5B8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: const [
                  TextSpan(
                      text:
                          'If cancelled before preparation, the amount will be adjusted or refunded. Check our cancellation '),
                  TextSpan(
                    text: 'policy',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Cancellation',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        ...List.generate(_reasons.length, (index) {
          final isSelected = _selectedReason == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedReason = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : const Color(0xFFDDDDDD),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : const Color(0xFFAAAAAA),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _reasons[index],
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMoreInfoField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: TextField(
        controller: _moreInfoController,
        maxLines: 4,
        style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Tell us more...',
          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: const Color(0xFFAAAAAA)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, bool isLoading) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleCancellation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Confirm Cancellation',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Go Back',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
