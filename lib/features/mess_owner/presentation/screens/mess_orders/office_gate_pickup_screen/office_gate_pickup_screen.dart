import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meal_house/core/router/app_routes.dart';

class OfficeGatePickupScreen extends StatefulWidget {
  const OfficeGatePickupScreen({super.key});

  @override
  State<OfficeGatePickupScreen> createState() => _OfficeGatePickupScreenState();
}

class _OfficeGatePickupScreenState extends State<OfficeGatePickupScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#8429',
      'status': 'READY',
      'dishName': 'Executive Veg Thali',
      'qty': '02',
      'image':
          'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=300',
      'imageLabel':
          'Executive Veg Thali with rice, dal, sabzi, roti and papad on a steel plate',
    },
    {
      'id': '#8430',
      'status': 'READY',
      'dishName': 'North Indian Deluxe Thali',
      'qty': '05',
      'image':
          'https://images.pexels.com/photos/958545/pexels-photo-958545.jpeg?auto=compress&cs=tinysrgb&w=300',
      'imageLabel':
          'North Indian Deluxe Thali with naan, paneer, dal makhani and rice on a steel plate',
    },
    {
      'id': '#8431',
      'status': 'PREPARING',
      'dishName': 'Mini Lunch Pack',
      'qty': '08',
      'image':
          'https://images.pixabay.com/photo/2017/09/16/19/21/salad-2756467_640.jpg',
      'imageLabel': 'Mini Lunch Pack with rice and curry in a steel tiffin box',
    },
    {
      'id': '#8432',
      'status': 'READY',
      'dishName': 'South Indian Special',
      'qty': '03',
      'image':
          'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg?auto=compress&cs=tinysrgb&w=300',
      'imageLabel':
          'South Indian Special with idli, sambar, coconut chutney and vada on a banana leaf',
    },
  ];

  List<Map<String, dynamic>> get _filteredOrders {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _orders;
    return _orders
        .where(
          (o) =>
              o['id'].toLowerCase().contains(query) ||
              o['dishName'].toLowerCase().contains(query),
        )
        .toList();
  }

  int get _totalPlates {
    return _orders.fold(0, (sum, o) => sum + int.parse(o['qty'] as String));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Office Gate Pickup',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1F2E),
              ),
            ),
            Text(
              'STATION ID: #OG-442',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE8622A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt, color: Color(0xFF1A1F2E)),
            onPressed: () {
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1F2E)),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.updateOrderStatusScreen);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF1A1F2E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Order ID or Dish...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF9E9E9E),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9E9E9E),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lunch Orders',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1F2E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD5B8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'TODAY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE8622A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Order Cards
                ..._filteredOrders.map((order) => _buildOrderCard(order)),
              ],
            ),
          ),
          // Bottom Summary Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final bool isReady = order['status'] == 'READY';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order['id'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isReady
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isReady
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFFFFB74D),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          order['status'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isReady
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order['dishName'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Color(0xFFE8622A),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Qty: ${order['qty']} plates',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F2E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: order['image'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFFF0F0F0),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE8622A),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFFF0F0F0),
                  child: const Icon(Icons.restaurant, color: Color(0xFFE8622A)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFFE8622A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Volume',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          '$_totalPlates plates',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1F2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Orders Count',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        _orders.length.toString().padLeft(2, '0'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1F2E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All pickups confirmed!',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE8622A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 22,
                  ),
                  label: Text(
                    'Confirm All Pickups',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
