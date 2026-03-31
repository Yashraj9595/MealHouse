import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/di/service_locator.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/features/mess_owner/domain/repositories/mess_repository.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';

class TodaysMenuScreen extends StatefulWidget {
  final String? initialTab;

  const TodaysMenuScreen({super.key, this.initialTab});

  @override
  State<TodaysMenuScreen> createState() => _TodaysMenuScreenState();
}

class _TodaysMenuScreenState extends State<TodaysMenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessRepository _messRepository = sl<MessRepository>();
  
  MenuModel? _menu;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    int initialIndex = 1; // Default to Lunch
    if (widget.initialTab != null) {
      if (widget.initialTab == 'Breakfast') {
        initialIndex = 0;
      } else if (widget.initialTab == 'Lunch') initialIndex = 1;
      else if (widget.initialTab == 'Dinner') initialIndex = 2;
      else if (widget.initialTab == 'Extra') initialIndex = 3;
    }
    _tabController = TabController(length: 4, vsync: this, initialIndex: initialIndex);
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final messes = await _messRepository.getMyMesses();
      if (messes.isNotEmpty) {
        final menu = await _messRepository.getMenu(messes.first.id!);
        if (mounted) {
          setState(() {
            _menu = menu;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading menu: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMenuItem(MenuItemModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && _menu != null) {
      try {
        final updatedItems = _menu!.items.where((i) => i.id != item.id && (i.name != item.name || i.price != item.price)).toList();
        final updatedMenu = _menu!.copyWith(items: updatedItems);
        await _messRepository.updateMenu(updatedMenu);
        _loadMenu();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
        }
      }
    }
  }

  Future<void> _toggleAvailability(MenuItemModel item) async {
    if (_menu == null) return;
    
    try {
      final updatedItems = _menu!.items.map((i) {
        if (i.name == item.name && i.category == item.category && i.price == item.price) {
          return i.copyWith(isAvailable: !i.isAvailable);
        }
        return i;
      }).toList();
      
      final updatedMenu = _menu!.copyWith(items: updatedItems);
      await _messRepository.updateMenu(updatedMenu);
      
      if (mounted) {
        setState(() {
          _menu = updatedMenu;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.name}" marked as ${!item.isAvailable ? 'available' : 'sold out'}'),
            backgroundColor: !item.isAvailable ? const Color(0xFF16A34A) : const Color(0xFF374151),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void didUpdateWidget(TodaysMenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab && widget.initialTab != null) {
      int newIndex = 1;
      if (widget.initialTab == 'Breakfast') {
        newIndex = 0;
      } else if (widget.initialTab == 'Lunch') newIndex = 1;
      else if (widget.initialTab == 'Dinner') newIndex = 2;
      else if (widget.initialTab == 'Extra') newIndex = 3;
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCustomAppBar(),
        _buildTabBar(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8650A)))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildMealTab('Breakfast'),
                  _buildMealTab('Lunch'),
                  _buildMealTab('Dinner'),
                  _buildMealTab('Extra'),
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Today's Menu",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1F2E),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.addMenuItemScreen);
              _loadMenu(); // Refresh after adding
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAD1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 18, color: Color(0xFFE8650A)),
                  const SizedBox(width: 4),
                  Text(
                    'Add New',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE8650A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFE8650A),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        indicatorColor: const Color(0xFFE8650A),
        indicatorWeight: 3,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Breakfast'),
          Tab(text: 'Lunch'),
          Tab(text: 'Dinner'),
          Tab(text: 'Extra'),
        ],
      ),
    );
  }

  Widget _buildMealTab(String category) {
    if (_menu == null || _menu!.items.isEmpty) {
      return _buildEmptyState(category);
    }

    final items = _menu!.items.where((item) => item.mealType.any((mt) => mt.toLowerCase() == category.toLowerCase())).toList();
    
    if (items.isEmpty) {
      return _buildEmptyState(category);
    }

    return RefreshIndicator(
      onRefresh: _loadMenu,
      color: const Color(0xFFE8650A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${category.toUpperCase()} ITEMS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            );
          }
          final item = items[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMenuCard(item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No $category items added yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.addMenuItemScreen);
              _loadMenu();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Menu Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _buildImage(item.image),
                ),
                if (!item.isAvailable)
                  Positioned.fill(
                    child: Container(color: Colors.black.withAlpha(120)),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.isAvailable ? const Color(0xFF16A34A) : const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.isAvailable ? 'AVAILABLE' : 'SOLD OUT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1F2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                           final fullIndex = _menu?.items.indexOf(item);
                           await Navigator.pushNamed(
                            context, 
                            AppRoutes.addMenuItemScreen,
                            arguments: {'item': item, 'index': fullIndex},
                           );
                           _loadMenu();
                        } else if (value == 'delete') {
                           _deleteMenuItem(item);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                      child: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF), size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.description ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSolidButton(
                        item.isAvailable ? 'Mark Sold Out' : 'Mark Available', 
                        () => _toggleAvailability(item),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildOutlineButton('Edit Menu', () async {
                       final fullIndex = _menu?.items.indexOf(item);
                       await Navigator.pushNamed(
                        context, 
                        AppRoutes.addMenuItemScreen,
                        arguments: {'item': item, 'index': fullIndex},
                       );
                       _loadMenu();
                    })),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? image) {
    if (image == null || image.isEmpty) {
      return Container(
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.restaurant, size: 48, color: Color(0xFF9CA3AF)),
      );
    }
    
    if (image.startsWith('data:image')) {
      final base64String = image.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
      );
    }
    
    return Image.network(
      image.startsWith('http') ? image : 'http://localhost:5000$image',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFFE5E7EB),
        child: const Icon(Icons.restaurant, size: 48, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  Widget _buildSolidButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1F2E),
          ),
        ),
      ),
    );
  }
}
