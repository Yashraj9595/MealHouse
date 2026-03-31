import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const Color _orange = Color(0xFFD4541B);
  static const Color _bg = Color(0xFFF2F2F7);

  int _activeFilterIndex = 0;
  int _activeNavIndex = 1; // History tab active

  final List<String> _filters = ['All', 'Payments', 'Recharges', 'Refunds'];

  final List<Map<String, dynamic>> _todayTransactions = [
    {
      'title': 'Uber Taxi Ride',
      'subtitle': 'Pickup: 123 Main St, New York',
      'time': '10:30 AM',
      'id': '#TR9821',
      'amount': '-\$24.50',
      'isCredit': false,
      'icon': Icons.local_taxi_rounded,
      'iconBg': Color(0xFFFFEDE5),
      'iconColor': Color(0xFFD4541B),
    },
    {
      'title': 'Wallet Recharge',
      'subtitle': 'From: Bank Account ****4321',
      'time': '09:15 AM',
      'id': '#RC1024',
      'amount': '+\$100.00',
      'isCredit': true,
      'icon': Icons.account_balance_wallet_rounded,
      'iconBg': Color(0xFFE5F5EC),
      'iconColor': Color(0xFF2D7A4F),
    },
  ];

  final List<Map<String, dynamic>> _yesterdayTransactions = [
    {
      'title': 'Starbucks Coffee',
      'subtitle': 'Store: #504 Times Square',
      'time': '04:45 PM',
      'id': '#TR7732',
      'amount': '-\$8.20',
      'isCredit': false,
      'icon': Icons.shopping_bag_rounded,
      'iconBg': Color(0xFFFFEDE5),
      'iconColor': Color(0xFFD4541B),
    },
    {
      'title': 'Refund: Zara Store',
      'subtitle': 'Reference: Returns #ZR-452',
      'time': '01:20 PM',
      'id': '#RF2210',
      'amount': '+\$45.99',
      'isCredit': true,
      'icon': Icons.arrow_back_rounded,
      'iconBg': Color(0xFFE5EEFF),
      'iconColor': Color(0xFF2563EB),
    },
    {
      'title': 'Italian Bistro',
      'subtitle': 'Pickup: 45th Street Plaza',
      'time': '12:10 PM',
      'id': '#TR6615',
      'amount': '-\$52.00',
      'isCredit': false,
      'icon': Icons.restaurant_rounded,
      'iconBg': Color(0xFFFFEDE5),
      'iconColor': Color(0xFFD4541B),
    },
  ];

  List<Map<String, dynamic>> get _filteredToday {
    if (_activeFilterIndex == 0) return _todayTransactions;
    if (_activeFilterIndex == 1) {
      return _todayTransactions
          .where(
            (t) =>
                !(t['isCredit'] as bool) &&
                t['id'].toString().startsWith('#TR'),
          )
          .toList();
    }
    if (_activeFilterIndex == 2) {
      return _todayTransactions
          .where((t) => t['id'].toString().startsWith('#RC'))
          .toList();
    }
    if (_activeFilterIndex == 3) {
      return _todayTransactions
          .where((t) => t['id'].toString().startsWith('#RF'))
          .toList();
    }
    return _todayTransactions;
  }

  List<Map<String, dynamic>> get _filteredYesterday {
    if (_activeFilterIndex == 0) return _yesterdayTransactions;
    if (_activeFilterIndex == 1) {
      return _yesterdayTransactions
          .where(
            (t) =>
                !(t['isCredit'] as bool) &&
                t['id'].toString().startsWith('#TR'),
          )
          .toList();
    }
    if (_activeFilterIndex == 2) {
      return _yesterdayTransactions
          .where((t) => t['id'].toString().startsWith('#RC'))
          .toList();
    }
    if (_activeFilterIndex == 3) {
      return _yesterdayTransactions
          .where((t) => t['id'].toString().startsWith('#RF'))
          .toList();
    }
    return _yesterdayTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Transaction History',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          // Transaction List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (_filteredToday.isNotEmpty) ...[
                  _buildDateHeader('TODAY'),
                  const SizedBox(height: 8),
                  ..._filteredToday.map((t) => _buildTransactionItem(t)),
                ],
                if (_filteredYesterday.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDateHeader('YESTERDAY'),
                  const SizedBox(height: 8),
                  ..._filteredYesterday.map((t) => _buildTransactionItem(t)),
                ],
                if (_filteredToday.isEmpty && _filteredYesterday.isEmpty)
                  _buildEmptyState(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(_filters.length, (index) {
              final bool isActive = index == _activeFilterIndex;
              return GestureDetector(
                onTap: () => setState(() => _activeFilterIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? _orange : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    _filters[index],
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _orange : const Color(0xFF8A8A8A),
                    ),
                  ),
                ),
              );
            }),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withAlpha(40)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6B6B6B),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isCredit = transaction['isCredit'] as bool;
    final Color amountColor = isCredit
        ? const Color(0xFF2D7A4F)
        : const Color(0xFF1A1A1A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: transaction['iconBg'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              transaction['icon'] as IconData,
              color: transaction['iconColor'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Title & details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  transaction['subtitle'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8A8A),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction['time']} • ID: ${transaction['id']}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount
          Text(
            transaction['amount'] as String,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: Colors.grey.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'No transactions found',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final List<Map<String, dynamic>> navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
      },
      {
        'label': 'History',
        'icon': Icons.history_rounded,
        'activeIcon': Icons.history_rounded,
      },
      {
        'label': 'Cards',
        'icon': Icons.credit_card_outlined,
        'activeIcon': Icons.credit_card_rounded,
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final bool isActive = index == _activeNavIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _activeNavIndex = index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isActive ? _orange : const Color(0xFF9E9E9E),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive ? _orange : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
