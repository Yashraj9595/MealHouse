import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/app_export.dart';
import '../../../presentation/widgets/category_chip_widget.dart';
import '../../../presentation/widgets/filter_bottom_sheet_widget.dart';
import '../../../presentation/widgets/mess_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isRefreshing = false;
  String currentLocation = 'Koramangala, Bangalore';

  final List<String> availableLocations = [
    'Koramangala, Bangalore',
    'Indiranagar, Bangalore',
    'Whitefield, Bangalore',
    'HSR Layout, Bangalore',
    'Jayanagar, Bangalore',
  ];

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
      "image": "https://images.unsplash.com/photo-1625398407796-82650a8c135f",
      "semanticLabel": "Traditional South Indian thali",
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
      "image": "https://images.unsplash.com/photo-1719995118613-32b6dfbfbf19",
      "semanticLabel": "Assorted North Indian dishes",
      "price": "₹150",
      "deliveryTime": "25-30 min",
      "isVeg": false,
    },
    
  ];

  List<Map<String, dynamic>> get _filteredMessData {
    if (_selectedCategory == 'All') {
      return _messData;
    }
    return _messData.where((mess) => mess['cuisine'] == _selectedCategory).toList();
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
      builder: (context) => FilterBottomSheetWidget(),
    );
  }

  void _onMessCardTap(Map<String, dynamic> mess) {
    HapticFeedback.lightImpact();
    Navigator.of(context, rootNavigator: true).pushNamed('/mess-detail-screen', arguments: mess);
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
            PopupMenuButton<String>(
              onSelected: (String location) {
                HapticFeedback.lightImpact();
                setState(() {
                  currentLocation = location;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Location updated to $location'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              itemBuilder: (BuildContext context) {
                return availableLocations.map((String location) {
                  return PopupMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList();
              },
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    currentLocation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(iconName: 'keyboard_arrow_down', size: 20),
                ],
              ),
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
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for mess or food...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomIconWidget(iconName: 'search', size: 24),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            height: 6.h,
            width: 6.h,
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
            child: Center(child: CustomIconWidget(iconName: 'tune', color: Colors.white, size: 24)),
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
              setState(() => _selectedCategory = _categories[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildMessList(ThemeData theme) {
    if (_isRefreshing) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }
    final filteredData = _filteredMessData;
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        itemCount: filteredData.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          return MessCardWidget(
            messData: filteredData[index],
            onTap: () => _onMessCardTap(filteredData[index]),
            onLongPress: () {},
          );
        },
      ),
    );
  }
}
