import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';

class CartBarWidget extends StatelessWidget {
  final int itemCount;
  final int total;
  final bool isTablet;
  final VoidCallback onCheckout;

  const CartBarWidget({
    super.key,
    required this.itemCount,
    required this.total,
    required this.isTablet,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, (bottomPadding > 0 ? bottomPadding : 16)),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cart info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CART',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      '$itemCount ${itemCount == 1 ? 'Item' : 'Items'} Selected',
                      key: ValueKey(itemCount),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Checkout button
            GestureDetector(
              onTap: onCheckout,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(77),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Checkout',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (total > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 1,
                        height: 16,
                        color: Colors.white.withAlpha(102),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹$total',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
