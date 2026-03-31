import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/shared/widgets/mess_owner_app_navigation.dart';
import './widgets/generate_distribution_button_widget.dart';
import './widgets/pickup_point_card_widget.dart';
import './widgets/total_orders_summary_widget.dart';

class PickupPointOrdersScreen extends StatefulWidget {
  const PickupPointOrdersScreen({super.key});

  @override
  State<PickupPointOrdersScreen> createState() =>
      _PickupPointOrdersScreenState();
}

class _PickupPointOrdersScreenState extends State<PickupPointOrdersScreen>
    with TickerProviderStateMixin {
  // TODO: Replace with Riverpod/Bloc for production
  int _currentNavIndex = 1; // Orders tab active

  late List<AnimationController> _cardControllers;
  late List<Animation<double>> _cardAnimations;

  static const List<Map<String, dynamic>> _pickupPointMaps = [
    {
      'id': 'pp_001',
      'name': 'Primary Delivery Point',
      'orderCount': 0,
      'iconCode': 0xe3ab,
    },
    {
      'id': 'pp_002',
      'name': 'Secondary Hub',
      'orderCount': 0,
      'iconCode': 0xe3ab,
    },
    {
      'id': 'pp_003',
      'name': 'Campus Collection',
      'orderCount': 0,
      'iconCode': 0xe3ab,
    },
  ];

  late List<PickupPointModel> _pickupPoints;
  late int _totalOrders;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with production data fetch
    _pickupPoints = _pickupPointMaps.map(PickupPointModel.fromMap).toList();
    _totalOrders = _pickupPoints.fold(0, (sum, p) => sum + p.orderCount);

    _cardControllers = List.generate(
      _pickupPoints.length,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 380),
        vsync: this,
      ),
    );

    _cardAnimations = _cardControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutCubic))
        .toList();

    // Staggered entrance
    for (int i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 120 + i * 70), () {
        if (mounted) _cardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNavTap(int index) {
    // TODO: Replace with named route navigation for production
    setState(() => _currentNavIndex = index);
  }

  void _onFilterTap() {
    // TODO: Connect to filter bottom sheet in production
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(),
    );
  }

  void _onPickupPointTap(PickupPointModel point) {
    // TODO: Navigate to pickup point detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Viewing orders for ${point.name}',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor: AppTheme.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onGenerateDistributionList() {
    // TODO: Connect to distribution list generation API
    showDialog(
      context: context,
      builder: (_) => _GenerateConfirmDialog(
        totalOrders: _totalOrders,
        pickupPoints: _pickupPoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leadingWidth: 52,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            splashColor: AppTheme.primary.withAlpha(26),
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'Pickup Point Orders',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              splashColor: AppTheme.primary.withAlpha(26),
              onTap: _onFilterTap,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.divider),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TotalOrdersSummaryWidget(totalOrders: _totalOrders),
          const SizedBox(height: 24),
          Text(
            'Pickup Points',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildPickupCards(),
          const SizedBox(height: 28),
          GenerateDistributionButtonWidget(onTap: _onGenerateDistributionList),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TotalOrdersSummaryWidget(totalOrders: _totalOrders),
              const SizedBox(height: 28),
              Text(
                'Pickup Points',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),
              ..._buildPickupCards(),
              const SizedBox(height: 32),
              GenerateDistributionButtonWidget(
                onTap: _onGenerateDistributionList,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPickupCards() {
    return List.generate(_pickupPoints.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FadeTransition(
          opacity: _cardAnimations[i],
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(_cardAnimations[i]),
            child: PickupPointCardWidget(
              point: _pickupPoints[i],
              onTap: () => _onPickupPointTap(_pickupPoints[i]),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Filter Bottom Sheet ────────────────────────────────────────────────────

class _FilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter Orders',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _FilterChipRow(
            label: 'Date',
            options: ['Today', 'This Week', 'This Month'],
            selected: 'Today',
          ),
          const SizedBox(height: 16),
          _FilterChipRow(
            label: 'Status',
            options: ['All', 'Pending', 'Distributed'],
            selected: 'All',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply Filter',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;

  const _FilterChipRow({
    required this.label,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return FilterChip(
              label: Text(
                opt,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {},
              backgroundColor: AppTheme.surface,
              selectedColor: AppTheme.primaryContainer,
              checkmarkColor: AppTheme.primary,
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Generate Confirm Dialog ────────────────────────────────────────────────

class _GenerateConfirmDialog extends StatelessWidget {
  final int totalOrders;
  final List<PickupPointModel> pickupPoints;

  const _GenerateConfirmDialog({
    required this.totalOrders,
    required this.pickupPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_bus_rounded,
                color: AppTheme.navy,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Generate Distribution List',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This will generate a distribution list for $totalOrders lunch orders across ${pickupPoints.length} pickup points.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...pickupPoints.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${p.orderCount} orders',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.divider),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Trigger distribution list API call
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Model ─────────────────────────────────────────────────────────────

class PickupPointModel {
  final String id;
  final String name;
  final int orderCount;
  final IconData icon;

  const PickupPointModel({
    required this.id,
    required this.name,
    required this.orderCount,
    required this.icon,
  });

  factory PickupPointModel.fromMap(Map<String, dynamic> map) {
    return PickupPointModel(
      id: map['id'] as String,
      name: map['name'] as String,
      orderCount: map['orderCount'] as int,
      icon: IconData(map['iconCode'] as int, fontFamily: 'MaterialIcons'),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'orderCount': orderCount,
    'iconCode': icon.codePoint,
  };
}
