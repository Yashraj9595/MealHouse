import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_export.dart';
import '../widgets/category_chip_widget.dart';
import '../widgets/filter_bottom_sheet_widget.dart';
import '../widgets/mess_card_widget.dart';

class CustomerHomeInitialPage extends StatefulWidget {
  const CustomerHomeInitialPage({super.key});

  @override
  State<CustomerHomeInitialPage> createState() =>
      _CustomerHomeInitialPageState();
}

class _CustomerHomeInitialPageState
    extends State<CustomerHomeInitialPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isRefreshing = false;

  final List<String> _categories = [
    'All',
    'South Indian',
    'North Indian',
    'Gujarati',
    'Bengali',
  ];

  final List<Map<String, dynamic>> _messData = [
    {
      "id": 1,
      "name": "Annapurna Mess",
      "cuisine": "South Indian",
      "rating": 4.5,
      "distance": "0.8 km",
      "availability": "available",
      "image":
          "https://images.unsplash.com/photo-1625398407796-82650a8c135f",
      "semanticLabel":
          "Traditional South Indian thali with rice, sambar, rasam, and various vegetable curries served on a banana leaf",
      "price": "₹120",
      "deliveryTime": "20-25 min",
      "isVeg": true,
    },
    {
      "id": 2,
      "name": "Punjabi Dhaba",
      "cuisine": "North Indian",
      "rating": 4.3,
      "distance": "1.2 km",
      "availability": "limited",
      "image":
          "https://images.unsplash.com/photo-1719995118613-32b6dfbfbf19",
      "semanticLabel":
          "Assorted North Indian dishes including butter chicken, naan bread, dal makhani, and paneer tikka on a wooden table",
      "price": "₹150",
      "deliveryTime": "25-30 min",
      "isVeg": false,
    },
    {
      "id": 3,
      "name": "Gujarati Thali House",
      "cuisine": "Gujarati",
      "rating": 4.7,
      "distance": "0.5 km",
      "availability": "available",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17d91308f-1766504685108.png",
      "semanticLabel":
          "Complete Gujarati thali with dhokla, kadhi, rotli, rice, and multiple sweet and savory dishes in small bowls",
      "price": "₹130",
      "deliveryTime": "15-20 min",
      "isVeg": true,
    },
    {
      "id": 4,
      "name": "Bengal Spice Kitchen",
      "cuisine": "Bengali",
      "rating": 4.4,
      "distance": "1.5 km",
      "availability": "available",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_116cad4f4-1764860394144.png",
      "semanticLabel":
          "Bengali fish curry with rice, accompanied by traditional side dishes and sweets on a traditional plate",
      "price": "₹140",
      "deliveryTime": "30-35 min",
      "isVeg": false,
    },
    {
      "id": 5,
      "name": "Sagar Ratna",
      "cuisine": "South Indian",
      "rating": 4.6,
      "distance": "2.0 km",
      "availability": "sold_out",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1760c8867-1769240037094.png",
      "semanticLabel":
          "Crispy masala dosa served with coconut chutney and sambar in traditional South Indian style",
      "price": "₹110",
      "deliveryTime": "35-40 min",
      "isVeg": true,
    },
  ];

  List<Map<String, dynamic>> get _filteredMessData {
    if (_selectedCategory == 'All') {
      return _messData;
    }
    return _messData
        .where((mess) => mess['cuisine'] == _selectedCategory)
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _showFilterBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheetWidget(),
    );
  }

  void _onMessCardTap(Map<String, dynamic> mess) {
    HapticFeedback.lightImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/mess-detail-screen', arguments: mess);
  }

  void _onMessCardLongPress(Map<String, dynamic> mess) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'favorite_border',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Add to Favorites',
                  style: theme.textTheme.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('Share', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  HapticFeedback.lightImpact();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'restaurant_menu',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text('View Menu', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _onMessCardTap(mess);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            SizedBox(height: 2.h),
            _buildSearchBar(theme),
            SizedBox(height: 2.h),
            _buildCategoryChips(theme),
            SizedBox(height: 2.h),
            Expanded(child: _buildMessList(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Location',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Koramangala, Bangalore',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search for mess or food...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            height: 6.h,
            width: 6.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CustomIconWidget(
                iconName: 'tune',
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    return SizedBox(
      height: 5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          return CategoryChipWidget(
            label: _categories[index],
            isSelected: _selectedCategory == _categories[index],
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedCategory = _categories[index];
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildMessList(ThemeData theme) {
    if (_isRefreshing) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    final filteredData = _filteredMessData;

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'restaurant',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No mess found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.colorScheme.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredData.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return MessCardWidget(
            messData: filteredData[index],
            onTap: () => _onMessCardTap(filteredData[index]),
            onLongPress: () => _onMessCardLongPress(filteredData[index]),
          );
        },
      ),
    );
  }
}
