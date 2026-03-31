import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:meal_house/features/user/presentation/providers/menu_provider.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

import './widgets/action_buttons_widget.dart';
import './widgets/cart_bar_widget.dart';
import './widgets/filter_tags_widget.dart';
import './widgets/hero_header_widget.dart';
import './widgets/info_cards_widget.dart';
import './widgets/meal_slot_buttons_widget.dart';
import './widgets/todays_thalis_widget.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen>
    with TickerProviderStateMixin {
  String _selectedMealSlot = 'Lunch';
  late AnimationController _cartBarController;
  late Animation<Offset> _cartBarSlide;

  @override
  void initState() {
    super.initState();
    _cartBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cartBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _cartBarController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _cartBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Try to get mess from arguments
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    MessModel? mess = arguments is MessModel ? arguments : null;
    
    // 2. If arguments are missing (browser refresh), try parsing the URL
    final String? routeName = ModalRoute.of(context)?.settings.name;
    if (mess == null && routeName != null && routeName.startsWith(AppRoutes.restaurantDetailPathPrefix)) {
      final String messId = routeName.substring(AppRoutes.restaurantDetailPathPrefix.length);
      
      // Fetch mess details using the provider
      final nearbyMessesAsync = ref.watch(nearbyMessesProvider);
      
      return nearbyMessesAsync.when(
        data: (messes) {
          final found = messes.where((m) => m.id == messId).toList();
          if (found.isNotEmpty) {
            mess = found.first;
          } else {
             // If not in nearby, we'd need a separate fetchMessById provider
             // For now, fallback to first if any, or error
             if (messes.isNotEmpty) mess = messes.first;
          }
          
          if (mess == null) return const Scaffold(body: Center(child: Text('Restaurant not found')));
          return _buildMainLayout(context, mess!);
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, s) => Scaffold(body: Center(child: Text('Error loading mess: $e'))),
      );
    }

    if (mess == null) {
      return const Scaffold(body: Center(child: Text('Restaurant not found')));
    }

    return _buildMainLayout(context, mess!);
  }

  Widget _buildMainLayout(BuildContext context, MessModel mess) {
    // Listen to Menu
    final menuAsync = ref.watch(menuProvider(mess.id!));
    
    // Listen to Cart
    final cartState = ref.watch(cartProvider);

    if (cartState.totalCount > 0 && cartState.messId == mess.id) {
      _cartBarController.forward();
    } else {
      _cartBarController.reverse();
    }

    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Hero Header with transparent AppBar
                HeroHeaderWidget(isTablet: isTablet, mess: mess),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Filter Tags
                        FilterTagsWidget(mess: mess),
                        const SizedBox(height: 20),
                        // Info Cards
                        InfoCardsWidget(isTablet: isTablet, mess: mess),
                        const SizedBox(height: 24),
                        // Meal Slot Buttons
                        MealSlotButtonsWidget(
                          selected: _selectedMealSlot,
                          onSelected: (slot) {
                            setState(() => _selectedMealSlot = slot);
                          },
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 16),
                        // Action Buttons
                        ActionButtonsWidget(isTablet: isTablet, mess: mess),
                        const SizedBox(height: 28),
                        // Today's Thalis Section
                        menuAsync.when(
                          data: (menu) {
                            if (menu == null) return const SizedBox.shrink();
                            // Client sorting/filtering might happen here based on meal slot or category (Veg/NonVeg).
                            // Currently showing all since no slot maps to menu item yet, can filter if needed.
                            final filteredItems = menu.items
                                .where((item) => 
                                    item.mealType.contains(_selectedMealSlot) || 
                                    item.mealType.contains('Extra')
                                ).toList();

                            return TodaysThalisWidget(
                              thalis: filteredItems,
                              cartItems: cartState.items,
                              onUpdateCart: (item, delta) {
                                if (delta > 0) {
                                  ref.read(cartProvider.notifier).addItem(item, mess.id!, selectedMealType: _selectedMealSlot);
                                } else {
                                  ref.read(cartProvider.notifier).removeItem(item.name);
                                }
                              },
                              isTablet: isTablet,
                              selectedSlot: _selectedMealSlot,
                              mess: mess,
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, s) => Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(child: Text('Error loading menu: $e')),
                          ),
                        ),
                        // Bottom padding for cart bar
                        SizedBox(height: cartState.totalCount > 0 ? 100 : 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Cart Bar (slides up from bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _cartBarSlide,
                child: CartBarWidget(
                  itemCount: cartState.totalCount,
                  total: cartState.totalAmount,
                  isTablet: isTablet,
                  onCheckout: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.orderSummary,
                      arguments: mess,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
