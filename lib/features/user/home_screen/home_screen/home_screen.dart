import 'package:meal_house/core/app_export.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/shared/widgets/location_header_widget.dart';
import 'package:meal_house/shared/notifications/tab_change_notification.dart';
import 'package:meal_house/core/constants/meal_enum.dart';
import 'package:meal_house/core/services/location_service.dart';
import 'package:meal_house/core/di/service_locator.dart';
import './widgets/home_meal_tabs_widget.dart';
import './widgets/home_mess_cards_widget.dart';
import './widgets/home_mess_nearby_widget.dart';
import './widgets/home_popular_today_widget.dart';
import './widgets/home_search_bar_widget.dart';
import './widgets/home_thali_cards_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedMealTab = 1; // 0=Breakfast, 1=Lunch, 2=Dinner
  // _selectedNavIndex removed (handled by MainNavigationWrapper)
  bool _isVoiceListening = false;

  late AnimationController _greetingAnimController;
  late Animation<double> _greetingFadeAnim;
  late Animation<Offset> _greetingSlideAnim;

  @override
  void initState() {
    super.initState();
    _initMealTabFromTime();

    _greetingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _greetingFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _greetingAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _greetingSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _greetingAnimController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _greetingAnimController.forward();
      _initMealTabFromTime();
      _syncLocationForTab(_selectedMealTab);
      // Trigger automatic location detection
      sl<LocationService>().autoDetectLocation();
    });
  }

  void _initMealTabFromTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 11) {
      _selectedMealTab = 0; // Breakfast
    } else if (hour >= 11 && hour < 16) {
      _selectedMealTab = 1; // Lunch
    } else {
      _selectedMealTab = 2; // Dinner
    }
  }

  void _syncLocationForTab(int index) {
    final meal = MealType.values[index];
    sl<LocationService>().switchToMealLocation(meal);
  }

  @override
  void dispose() {
    _greetingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Material(
      color: const Color(0xFFFFF7F2),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Location Header
          SliverToBoxAdapter(
            child: LocationHeaderWidget(
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notificationsScreen),
              onProfileTap: () =>
                  const TabChangeNotification(4).dispatch(context),
              onLocationTap: () => Navigator.pushNamed(
                context,
                AppRoutes.locationSelectionScreen,
              ),
            ),
          ),


          // Search Bar
          SliverToBoxAdapter(
            child: HomeSearchBarWidget(
              isListening: _isVoiceListening,
              onVoiceTap: () {
                // TODO: Integrate speech_to_text package for production
                setState(() => _isVoiceListening = !_isVoiceListening);
              },
            ),
          ),

          // Meal Tabs
          SliverToBoxAdapter(
            child: HomeMealTabsWidget(
              selectedIndex: _selectedMealTab,
              onTabChanged: (index) {
                setState(() => _selectedMealTab = index);
                _syncLocationForTab(index);
              },
            ),
          ),

          // Mess Cards Horizontal Scroll
          SliverToBoxAdapter(child: HomeMessCardsWidget(isTablet: isTablet)),

          // Popular Today Section
          SliverToBoxAdapter(
            child: HomePopularTodayWidget(
              selectedMealTab: _selectedMealTab,
              isTablet: isTablet,
            ),
          ),

          // Today's Thalis Near You
          SliverToBoxAdapter(
            child: HomeThaliCardsWidget(
              selectedMealTab: _selectedMealTab,
              isTablet: isTablet,
            ),
          ),

          // Mess Near You
          SliverToBoxAdapter(
            child: HomeMessNearbyWidget(
              onViewMapsTap: () {
                Navigator.pushNamed(context, AppRoutes.messNearYou);
              },
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
