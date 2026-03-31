import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class MenuStatusScreen extends StatefulWidget {
  const MenuStatusScreen({super.key});

  @override
  State<MenuStatusScreen> createState() => _MenuStatusScreenState();
}

class _MenuStatusScreenState extends State<MenuStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Menu Status',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2.5,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Not Available'),
                Tab(text: 'Sold Out'),
                Tab(text: 'Closed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_NotAvailableTab(), _SoldOutTab(), _ClosedTab()],
      ),
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

// ─── Not Available Tab ───────────────────────────────────────────────────────

class _NotAvailableTab extends StatelessWidget {
  const _NotAvailableTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration card
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 72,
                    color: AppTheme.primary,
                  ),
                  Positioned(
                    bottom: 52,
                    right: 108,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu Not Uploaded',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Today's menu is not available yet. The mess owner\nwill update the menu soon.",
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Refresh Page',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sold Out Tab ─────────────────────────────────────────────────────────────

class _SoldOutTab extends StatelessWidget {
  const _SoldOutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration card
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFEE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: _CartExclamationIcon()),
          ),
          const SizedBox(height: 24),
          Text(
            'Sold Out',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This meal is sold out. Try another meal from this\nmess.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'View Other Meals',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartExclamationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(painter: _CartPainter()),
    );
  }
}

class _CartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Cart body
    final cartPath = Path();
    cartPath.moveTo(w * 0.12, h * 0.22);
    cartPath.lineTo(w * 0.25, h * 0.22);
    cartPath.lineTo(w * 0.35, h * 0.65);
    cartPath.lineTo(w * 0.82, h * 0.65);
    cartPath.lineTo(w * 0.88, h * 0.35);
    cartPath.lineTo(w * 0.30, h * 0.35);
    canvas.drawPath(cartPath, paint);

    // Wheels
    final wheelPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.40, h * 0.80), w * 0.06, wheelPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.80), w * 0.06, wheelPaint);

    // Exclamation mark
    final exclamPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;
    // Line
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.62, h * 0.20),
        width: w * 0.08,
        height: h * 0.22,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, exclamPaint);
    // Dot
    canvas.drawCircle(Offset(w * 0.62, h * 0.50), w * 0.05, exclamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Closed Tab ───────────────────────────────────────────────────────────────

class _ClosedTab extends StatelessWidget {
  const _ClosedTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Illustration card
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 72, color: AppTheme.primary),
                  Positioned(
                    bottom: 50,
                    right: 104,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Closed pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8D8),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'CLOSED AT 11:30 AM',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ordering Closed',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ordering for this meal has closed. Lunch orders\nclosed at 11:30 AM.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD1D5DB),
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                disabledForegroundColor: AppTheme.textSecondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Order Unavailable',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
              ),
              _BottomNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                isActive: false,
              ),
              _BottomNavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                isActive: true,
              ),
              _BottomNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : Color(0xFF9CA3AF);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
