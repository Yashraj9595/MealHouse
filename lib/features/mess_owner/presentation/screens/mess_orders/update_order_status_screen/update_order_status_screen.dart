import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateOrderStatusScreen extends StatefulWidget {
  const UpdateOrderStatusScreen({super.key});

  @override
  State<UpdateOrderStatusScreen> createState() =>
      _UpdateOrderStatusScreenState();
}

class _UpdateOrderStatusScreenState extends State<UpdateOrderStatusScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#842',
      'name': 'Rajat Kumar',
      'currentStatus': 'PREPARING',
      'price': '\$12.50',
      'selectedStatus': 'Preparing',
      'isChecked': true,
    },
    {
      'id': '#843',
      'name': 'Simran Singh',
      'currentStatus': 'PREPARING',
      'price': '\$18.00',
      'selectedStatus': 'Preparing',
      'isChecked': false,
    },
    {
      'id': '#844',
      'name': 'Anjali Mehta',
      'currentStatus': 'PREPARING',
      'price': '\$24.00',
      'selectedStatus': 'Ready',
      'isChecked': true,
    },
    {
      'id': '#845',
      'name': 'Vikram Roy',
      'currentStatus': 'READY',
      'price': '\$9.00',
      'selectedStatus': 'Ready',
      'isChecked': false,
    },
  ];

  final List<String> _statusOptions = ['Preparing', 'Ready', 'Completed'];

  int get _selectedCount => _orders.where((o) => o['isChecked'] == true).length;

  @override
  void dispose() {
    _searchController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Order Status',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '12 Active',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE8622A),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Select orders to update',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Apply status changes to multiple orders at once.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF1A1A2E),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search order # or name',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFFAAAAAA),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFFAAAAAA),
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Color(0xFF1A1A2E),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Order cards
                    ...List.generate(_orders.length, (index) {
                      return _buildOrderCard(index);
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    final order = _orders[index];
    final bool isChecked = order['isChecked'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _orders[index]['isChecked'] = !isChecked;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? const Color(0xFFE8622A)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFFE8622A)
                          : const Color(0xFFCCCCCC),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${order['id']} - ${order['name']}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CURRENT: ${order['currentStatus']}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF999999),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                order['price'],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE8622A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: List.generate(_statusOptions.length, (sIndex) {
                final status = _statusOptions[sIndex];
                final bool isActive = order['selectedStatus'] == status;
                final bool isFirst = sIndex == 0;
                final bool isLast = sIndex == _statusOptions.length - 1;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _orders[index]['selectedStatus'] = status;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: isFirst
                              ? const Radius.circular(9)
                              : Radius.zero,
                          bottomLeft: isFirst
                              ? const Radius.circular(9)
                              : Radius.zero,
                          topRight: isLast
                              ? const Radius.circular(9)
                              : Radius.zero,
                          bottomRight: isLast
                              ? const Radius.circular(9)
                              : Radius.zero,
                        ),
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFFE8622A),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? const Color(0xFFE8622A)
                                : const Color(0xFF888888),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _selectedCount > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Saved changes for $_selectedCount order(s)',
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                          backgroundColor: const Color(0xFFE8622A),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                disabledBackgroundColor: const Color(0xFFE8622A).withAlpha(128),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                'Save Changes ($_selectedCount)',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF555555),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
