import 'package:MealHouse/core/app_export.dart';
import '../../../presentation/widgets/filter_bottom_sheet_widget.dart';
import '../../../presentation/widgets/mess_card_widget.dart';
import '../../../presentation/widgets/featured_mess_widget.dart';
import '../../../presentation/widgets/promotional_banner_widget.dart';
import 'package:MealHouse/features/user/data/models/mess_model.dart';
import 'package:MealHouse/core/network/api_client.dart';
import 'package:MealHouse/core/network/base_response.dart';
import 'package:MealHouse/core/constants/api_constants.dart';
import 'package:MealHouse/core/config/env_config.dart';
import 'package:MealHouse/core/utils/api_test.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  
  final ApiClient _apiClient = ApiClient();
  List<MessModel> _messData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMesses();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final List<String> _categories = [
    'All',
    'South Indian',
    'North Indian',
    'Gujarati',
    'Bengali',
    'Chinese',
    'Continental',
  ];

  Future<void> _loadMesses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Debug: Print the API URL being used
      print('🔍 Loading messes from: ${Environment.config.baseUrl}/messes');

      // Don't load mock data immediately - let loading state show
      final response = await _apiClient.get(ApiConstants.messes).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('API timeout after 10 seconds'),
      );
      
      print('✅ API Response Status: ${response.statusCode}');
      print('✅ API Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
         final baseResponse = response.toBaseResponse<Map<String, dynamic>>();
         
         if (baseResponse.success) {
           final messesData = baseResponse.getListData((json) => MessModel.fromJson(json));
           
           if (messesData.isNotEmpty) {
             if (mounted) {
               setState(() {
                 _messData = messesData;
                 _error = null;
               });
             }
             print('✅ Successfully loaded ${messesData.length} messes');
           } else {
             // No data from API, use mock data
             if (mounted) {
               setState(() {
                 _messData = _getMockData();
                 _error = null;
               });
             }
             print('⚠️ No data from API, using mock data');
           }
         } else {
           throw Exception(baseResponse.message);
         }
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      if (mounted) {
        setState(() {
          _error = 'Network connection failed. Please check your internet connection.';
          // Load mock data when network fails
          _messData = _getMockData();
        });
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      if (mounted) {
        setState(() {
          _error = 'Request timed out. Backend server may not be running.';
          // Load mock data when timeout occurs
          _messData = _getMockData();
        });
      }
    } catch (e) {
      print('Error loading messes: $e'); // Debug log
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: ${e.toString()}';
          // Only load mock data if we have no data at all
          if (_messData.isEmpty) {
            _messData = _getMockData();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<MessModel> _getMockData() {
    return [
      MessModel(
        id: "1",
        name: "Annapurna Mess",
        owner: "owner1",
        cuisine: "South Indian",
        rating: 4.5,
        distance: "0.8 km",
        image: "https://images.unsplash.com/photo-1625398407796-82650a8c135f",
        price: "120",
        deliveryTime: "20-25 min",
        isVeg: true,
        isActive: true,
      ),
      MessModel(
        id: "2",
        name: "Punjabi Dhaba",
        owner: "owner2",
        cuisine: "North Indian",
        rating: 4.2,
        distance: "1.2 km",
        image: "https://images.unsplash.com/photo-1585032226651-759b368d7246",
        price: "150",
        deliveryTime: "25-30 min",
        isVeg: false,
        isActive: true,
      ),
      MessModel(
        id: "3",
        name: "Gujarati Thali",
        owner: "owner3",
        cuisine: "Gujarati",
        rating: 4.7,
        distance: "1.5 km",
        image: "https://images.unsplash.com/photo-1601050690597-784da6911c5c",
        price: "130",
        deliveryTime: "30-35 min",
        isVeg: true,
        isActive: true,
      ),
      MessModel(
        id: "4",
        name: "Bengali Kitchen",
        owner: "owner4",
        cuisine: "Bengali",
        rating: 4.3,
        distance: "2.0 km",
        image: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624",
        price: "140",
        deliveryTime: "35-40 min",
        isVeg: false,
        isActive: true,
      ),
      MessModel(
        id: "5",
        name: "Chinese Wok",
        owner: "owner5",
        cuisine: "Chinese",
        rating: 4.1,
        distance: "0.5 km",
        image: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
        price: "160",
        deliveryTime: "15-20 min",
        isVeg: false,
        isActive: true,
      ),
      MessModel(
        id: "6",
        name: "Continental Cafe",
        owner: "owner6",
        cuisine: "Continental",
        rating: 4.6,
        distance: "1.8 km",
        image: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0",
        price: "200",
        deliveryTime: "40-45 min",
        isVeg: false,
        isActive: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredMesses = _getFilteredMesses();
    final featuredMesses = _messData.where((mess) => mess.rating >= 4.5).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? _buildLoadingState()
            : _messData.isEmpty && _error != null
                ? _buildErrorState()
                : _buildContentWithBanner(theme, filteredMesses, featuredMesses),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 2.h),
          Text(
            'Loading messes...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Failed to load data',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          if (_error != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_messData.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Text(
              'Showing offline data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () {
              // Clear error and retry
              setState(() {
                _error = null;
              });
              _loadMesses();
            },
            icon: const Icon(Icons.refresh),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWithBanner(ThemeData theme, List<MessModel> filteredMesses, List<MessModel> featuredMesses) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Show error banner if there's an error but we have data
        if (_error != null)
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 20),
                  SizedBox(width: 1.w),
                  Expanded(
                    child: Text(
                      'Offline mode: $_error',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                      _loadMesses();
                    },
                    child: Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        
        // Original content
        ..._buildContent(theme, filteredMesses, featuredMesses),
      ],
    );
  }

  List<Widget> _buildContent(ThemeData theme, List<MessModel> filteredMesses, List<MessModel> featuredMesses) {
    return [
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCompactHeader(theme),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        // Zomato-style promotional banner
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              height: 140,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFe13742),
                        const Color(0xFFf04f5f),
                        const Color(0xFFea737b),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 4.w,
                        top: 3.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '50% OFF',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'First Order',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Use code MEAL50',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        // Zomato-style offers section
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              alignment: Alignment.center,
              height: 110,
              padding: EdgeInsets.all(3.w).copyWith(right: 0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.fromBorderSide(
                  BorderSide(color: const Color(0xffe6e9ef).withValues(alpha: 0.8), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Offers",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "Up to 60% OFF, Flat Discounts, and other great offers",
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: const Color(0xff9ea3b0),
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFe13742).withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'local_offer',
                        color: const Color(0xFFe13742),
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        if (featuredMesses.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: FeaturedMessWidget(
                featuredMesses: featuredMesses,
                onMessTap: _onMessCardTap,
              ),
            ),
          ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        // Zomato-style "What's on your mind?" section
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xffe6e9ef),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          "WHAT'S ON YOUR MIND?",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            color: const Color(0xff586377),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xffe6e9ef),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 180,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: ListView.builder(
                    padding: EdgeInsets.only(right: 4.w),
                    itemCount: _categories.length - 1, // Exclude 'All'
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final category = _categories[index + 1];
                      return Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: _getCategoryIcon(category),
                                    color: theme.colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                category,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        // Zomato-style filter chips
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(right: 4.w).copyWith(left: 2.w),
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(theme, 'tune', 'Sort', true, () {}),
                _buildFilterChip(theme, 'near_me', 'Nearest', false, () {}),
                _buildFilterChip(theme, 'star', 'Rating 4.0+', false, () {}),
                _buildFilterChip(theme, 'eco', 'Pure Veg', false, () {}),
                _buildFilterChip(theme, 'new_releases', 'New Arrivals', false, () {}),
                _buildFilterChip(theme, 'restaurant', 'Cuisines', true, () {}),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: true,
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'All Messes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (_isSearching)
                  Text(
                    '${filteredMesses.length} results',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 1.h)),
        
        // Zomato-style restaurant count
        SliverToBoxAdapter(
          child: Center(
            child: Text(
              "${filteredMesses.length} messes delivering to you",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xff9ea3b0),
                fontSize: 14,
              ),
            ),
          ),
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 2.h)),
        
        // Zomato-style restaurant list
        SliverList.builder(
          itemCount: filteredMesses.length,
          itemBuilder: (context, index) {
            final mess = filteredMesses[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: _buildZomatoStyleMessCard(theme, mess),
            );
          },
        ),
        
        SliverToBoxAdapter(child: SizedBox(height: 4.h)),
    ];
  }

  List<MessModel> _getFilteredMesses() {
    var filtered = _messData;
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((mess) => mess.cuisine == _selectedCategory).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered = filtered.where((mess) => 
        mess.name.toLowerCase().contains(searchQuery) ||
        mess.cuisine.toLowerCase().contains(searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  Future<void> _handleRefresh() async {
    await _loadMesses();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheetWidget(),
    );
  }

  void _onMessCardTap(MessModel mess) {
    Navigator.pushNamed(
      context,
      '/mess-detail-screen',
      arguments: mess,
    );
  }

  void _showMessOptions(MessModel mess) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text(
                    mess.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 2.h),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'favorite_border',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Add to Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'share',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Share Mess'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'bug_report',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Test API Connection'),
                    onTap: () {
                      Navigator.pop(context);
                      _testApiConnection();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testApiConnection() async {
    print('\n🔧 Testing API Connection from Flutter App...');
    ApiTest.printConfiguration();
    await ApiTest.testConnection();
  }

  Widget _buildCompactHeader(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    // TODO: Navigate to location selection
                  },
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: const Color(0xFFe13742),
                        size: 24,
                      ),
                      SizedBox(width: 1.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Koramangala',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                WidgetSpan(
                                  child: CustomIconWidget(
                                    iconName: 'keyboard_arrow_down',
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Bangalore, Karnataka',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xff586377),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 2, left: 1),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: const Color(0xffb8b9bf),
                        width: 1,
                      ),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: CustomIconWidget(
                    iconName: 'language',
                    color: const Color(0xff586377),
                    size: 16,
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to profile
                  },
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                },
                onTap: () {
                  // TODO: Navigate to search screen
                },
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Restaurant name or a dish...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _isSearching = false;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    // This method is kept for backward compatibility but no longer used
    return Container();
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'South Indian':
        return 'rice_bowl';
      case 'North Indian':
        return 'restaurant';
      case 'Gujarati':
        return 'lunch_dining';
      case 'Bengali':
        return 'set_meal';
      case 'Chinese':
        return 'ramen_dining';
      case 'Continental':
        return 'dinner_dining';
      default:
        return 'restaurant';
    }
  }

  Widget _buildFilterChip(ThemeData theme, String iconName, String label, bool hasMultiOption, VoidCallback onClick) {
    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffe6e9ef)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: const Color(0xff586377),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xff586377),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasMultiOption) ...[
                SizedBox(width: 0.5.w),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: const Color(0xff586377),
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZomatoStyleMessCard(ThemeData theme, MessModel mess) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onMessCardTap(mess),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: mess.image.isNotEmpty
                        ? Image.network(
                            mess.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'restaurant',
                                    color: Colors.grey[600],
                                    size: 40,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: CustomIconWidget(
                              iconName: 'restaurant',
                              color: Colors.grey[600],
                              size: 40,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 1.h,
                    left: 1.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: const Color(0xFFe13742),
                            size: 16,
                          ),
                          SizedBox(width: 0.5.w),
                          Text(
                            mess.deliveryTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFe13742),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (mess.isVeg)
                    Positioned(
                      top: 1.h,
                      right: 1.w,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'eco',
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Content section
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mess.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'star',
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 0.5.w),
                            Text(
                              mess.rating.toString(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: const Color(0xff586377),
                        size: 16,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        mess.distance,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff586377),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'restaurant',
                        color: const Color(0xff586377),
                        size: 16,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        mess.cuisine,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff586377),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: 1,
                    color: const Color(0xffe6e9ef),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${Random().nextInt(30) + 20}% OFF up to ₹${Random().nextInt(100) + 50}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFe13742),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'local_offer',
                        color: const Color(0xFFe13742),
                        size: 16,
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
}
