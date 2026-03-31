import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class RateReviewScreen extends StatefulWidget {
  final MessModel mess;
  
  const RateReviewScreen({super.key, required this.mess});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int _selectedRating = 5;
  final Set<String> _selectedTags = {'Delicious'};
  final TextEditingController _reviewController = TextEditingController();

  final List<String> _tags = [
    'Delicious', 'On Time', 'Clean Packaging', 'Good Quantity', 'Value for money',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('Rate Your Meal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 32),
            Text('How was your meal from ${widget.mess.name}?', textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildStarRating(),
            const SizedBox(height: 32),
            _buildTags(),
            const SizedBox(height: 32),
            _buildReviewField(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.restaurant, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.mess.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.mess.cuisineType, style: const TextStyle(color: Colors.grey)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(index < _selectedRating ? Icons.star : Icons.star_border, size: 40, color: AppTheme.primary),
          onPressed: () => setState(() => _selectedRating = index + 1),
        );
      }),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _tags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (v) => setState(() => isSelected ? _selectedTags.remove(tag) : _selectedTags.add(tag)),
          selectedColor: AppTheme.primaryLight,
          checkmarkColor: AppTheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildReviewField() {
    return TextField(
      controller: _reviewController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Tell us what you loved!',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
           Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeScreen, (r) => false);
        },
        child: const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
