import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class TrackOrderScreen extends StatelessWidget {
  final MessModel mess;
  
  const TrackOrderScreen({super.key, required this.mess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Track Order', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildMessCard(),
            const SizedBox(height: 24),
            _buildPickupInfo(),
            const SizedBox(height: 24),
            Text('Timeline', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.delivery_dining, size: 40, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PREPARING', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text('Your meal is being cooked', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildMessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _row(Icons.storefront, 'MESS', mess.name),
          const Divider(height: 24),
          _row(Icons.restaurant, 'CUISINE', mess.cuisineType),
        ],
      ),
    );
  }

  Widget _buildPickupInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PICKUP POINT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(mess.address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.map_outlined, size: 48, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _step('Order Placed', 'Confirmed at 1:30 PM', true, false),
        _step('Preparing', 'Started at 1:45 PM', true, true),
        _step('Ready for Pickup', 'Estimated 2:00 PM', false, false),
      ],
    );
  }

  Widget _step(String title, String sub, bool done, bool active) {
    return Row(
      children: [
        Column(children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : Colors.grey),
          Container(width: 2, height: 30, color: Colors.grey.shade300),
        ]),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: active ? AppTheme.primary : Colors.black)),
          Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
      ],
    );
  }
}