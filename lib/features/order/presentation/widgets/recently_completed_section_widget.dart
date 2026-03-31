import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/custom_image_widget.dart';
import '../../data/models/order_model.dart';

class RecentlyCompletedSectionWidget extends StatelessWidget {
  final List<OrderModel> orders;
  final ValueChanged<OrderModel> onReorder;
  final VoidCallback onViewAll;

  const RecentlyCompletedSectionWidget({
    super.key,
    required this.orders,
    required this.onReorder,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENTLY COMPLETED',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...orders.map(
          (order) => _CompletedMiniCard(
            order: order,
            onReorder: () => onReorder(order),
          ),
        ),
      ],
    );
  }
}

class _CompletedMiniCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback onReorder;

  const _CompletedMiniCard({required this.order, required this.onReorder});

  @override
  State<_CompletedMiniCard> createState() => _CompletedMiniCardState();
}

class _CompletedMiniCardState extends State<_CompletedMiniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: widget.order.imageUrl,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  semanticLabel: widget.order.imageSemanticLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.mealName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.order.date} • ${widget.order.providerName}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: widget.onReorder,
                      child: Text(
                        'Reorder Now',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
