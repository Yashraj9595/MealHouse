import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  static const Color _orange = Color(0xFFD4541B);
  static const Color _bg = Color(0xFFF5F5F5);

  int _selectedRechargeIndex = 2; // ₹500 selected by default
  final TextEditingController _customAmountController = TextEditingController();
  // _activeNavIndex removed (handled by MainNavigationWrapper)

  final List<Map<String, dynamic>> _rechargeAmounts = [
    {'label': '₹100', 'value': 100},
    {'label': '₹200', 'value': 200},
    {'label': '₹500', 'value': 500},
    {'label': '₹1000', 'value': 1000},
  ];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Lunch Subscription',
      'date': '24 Oct, 12:30 PM',
      'amount': '-₹60',
      'type': 'DEDUCTED',
      'isCredit': false,
      'icon': Icons.restaurant,
      'iconBg': Color(0xFFFFE5E5),
      'iconColor': Color(0xFFD4541B),
    },
    {
      'title': 'UPI Top-up',
      'date': '22 Oct, 09:15 AM',
      'amount': '+₹500',
      'type': 'ADDED',
      'isCredit': true,
      'icon': Icons.account_balance_wallet,
      'iconBg': Color(0xFFE5F5EC),
      'iconColor': Color(0xFF2D7A4F),
    },
    {
      'title': 'Dinner Special',
      'date': '21 Oct, 08:45 PM',
      'amount': '-₹80',
      'type': 'DEDUCTED',
      'isCredit': false,
      'icon': Icons.dinner_dining,
      'iconBg': Color(0xFFFFE5E5),
      'iconColor': Color(0xFFD4541B),
    },
    {
      'title': 'Extra Curd Add-on',
      'date': '20 Oct, 01:10 PM',
      'amount': '-₹20',
      'type': 'DEDUCTED',
      'isCredit': false,
      'icon': Icons.fastfood,
      'iconBg': Color(0xFFF0F0F0),
      'iconColor': Color(0xFF8A8A8A),
    },
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
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
          'My Wallet',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history_rounded,
              color: Color(0xFFD4541B),
              size: 26,
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.transactionHistoryScreen,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Wallet Card
            _buildWalletCard(),
            const SizedBox(height: 24),
            // Quick Recharge
            _buildQuickRecharge(),
            const SizedBox(height: 16),
            // Custom Amount Input
            _buildCustomAmountInput(),
            const SizedBox(height: 24),
            // Recent Transactions
            _buildRecentTransactions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _orange,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Decorative card graphic (top-right)
            Positioned(
              right: -10,
              top: -10,
              child: Opacity(
                opacity: 0.18,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 22),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 30,
              top: 30,
              child: Opacity(
                opacity: 0.18,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(200),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '₹240',
                          style: GoogleFonts.dmSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        TextSpan(
                          text: '.00',
                          style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WALLET ID',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(180),
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'MS-9823-X40',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withAlpha(80),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRecharge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'QUICK RECHARGE',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A8A8A),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _rechargeAmounts.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedRechargeIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedRechargeIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _orange : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _orange : const Color(0xFFDDDDDD),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _rechargeAmounts[index]['label'] as String,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _orange,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAmountInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              '₹',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF8A8A8A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter custom amount',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFAAAAAA),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.rechargeWalletScreen);
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Add',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.transactionHistoryScreen);
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _orange,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_transactions.length, (index) {
          return _buildTransactionItem(_transactions[index]);
        }),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final bool isCredit = tx['isCredit'] as bool;
    final Color amountColor = isCredit
        ? const Color(0xFF2D7A4F)
        : const Color(0xFFB91C1C);
    final Color badgeBg = isCredit
        ? const Color(0xFFE5F5EC)
        : const Color(0xFFFFE5E5);
    final Color badgeText = isCredit
        ? const Color(0xFF2D7A4F)
        : const Color(0xFFB91C1C);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tx['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx['icon'] as IconData,
              color: tx['iconColor'] as Color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tx['date'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8A8A),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['amount'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx['type'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
    );
  }
}
