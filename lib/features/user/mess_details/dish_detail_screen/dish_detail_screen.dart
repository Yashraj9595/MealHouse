import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/theme/app_theme.dart';
import 'package:meal_house/core/router/app_routes.dart';
import 'package:meal_house/features/mess_owner/domain/models/menu_model.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_house/features/user/presentation/providers/menu_provider.dart';
import 'package:meal_house/features/user/presentation/providers/mess_provider.dart';

class DishDetailScreen extends ConsumerStatefulWidget {
  const DishDetailScreen({super.key});

  @override
  ConsumerState<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends ConsumerState<DishDetailScreen> {
  bool _autoReorder = false;

  @override
  Widget build(BuildContext context) {
    // 1. Try to get arguments passed directly via Navigator.push
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final Map<dynamic, dynamic>? args = arguments is Map ? arguments : null;
    
    MenuItemModel? item = args?['item'];
    MessModel? mess = args?['mess'];

    // 2. If arguments are missing (e.g. browser refresh), try parsing the URL
    final String? routeName = ModalRoute.of(context)?.settings.name;
    if (item == null && routeName != null && routeName.startsWith(AppRoutes.dishDetailPathPrefix)) {
      final segments = routeName.substring(AppRoutes.dishDetailPathPrefix.length).split('/');
      if (segments.length >= 2) {
        final messId = segments[0];
        final itemId = segments[1];
        
        // Fetch mess details and menu
        final messAsync = ref.watch(nearbyMessesProvider);
        final menuAsync = ref.watch(menuProvider(messId));

        return messAsync.when(
          data: (messes) {
            mess = messes.firstWhere((m) => m.id == messId, orElse: () => messes.isNotEmpty ? messes.first : null as dynamic);
            if (mess == null) {
               return const Scaffold(body: Center(child: Text('Mess not found')));
            }
            return menuAsync.when(
              data: (menu) {
                if (menu == null || menu.items.isEmpty) {
                  return const Scaffold(body: Center(child: Text('Menu not available')));
                }
                item = menu.items.firstWhere(
                  (i) => i.id == itemId || i.name == itemId, 
                  orElse: () => menu.items.first,
                );
                return _buildMainLayout(context, item, mess);
              },
              loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
              error: (e, s) => Scaffold(body: Center(child: Text('Error loading menu: $e'))),
            );
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, s) => Scaffold(body: Center(child: Text('Error loading mess: $e'))),
        );
      }
    }

    return _buildMainLayout(context, item, mess);
  }

  Widget _buildMainLayout(BuildContext context, MenuItemModel? item, MessModel? mess) {

    final String dishName = item?.name ?? 'Dish Name';
    final String price = item != null ? '₹${item.price.toInt()}' : '₹0';
    final String subtitle = (item?.description?.isNotEmpty == true) 
        ? item!.description! 
        : 'Delicious ${item?.mealType.isNotEmpty == true ? item!.mealType.join('/') : 'meal'} by ${mess?.name ?? 'your favourite mess'}';
    final String imageUrl = item?.image ?? (mess?.photos.isNotEmpty == true ? mess!.photos.first : 'https://images.pexels.com/photos/2474661/pexels-photo-2474661.jpeg');
    final int platesAvailable = item?.platesAvailable ?? 0;
    final List<String> ingredients = item?.ingredients ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero image section
                _buildHeroSection(context, imageUrl, platesAvailable),
                // White card content
                _buildContentCard(dishName, price, subtitle, ingredients, mess, item),
              ],
            ),
          ),
          // Fixed bottom Order Now button
          Positioned(bottom: 0, left: 0, right: 0, child: _buildOrderButton(item, mess)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    String imageUrl,
    int platesAvailable,
  ) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // Full-width hero image
          Image.network(
            imageUrl,
            width: double.infinity,
            height: 320,
            fit: BoxFit.cover,
            semanticLabel:
                'Delicious Indian thali meal with curry, rice, chapati and sides served in a white bowl on blue cloth',
            errorBuilder: (_, _, _) => Container(
              width: double.infinity,
              height: 320,
              color: Colors.grey.shade300,
              child: const Icon(Icons.restaurant, size: 64, color: Colors.grey),
            ),
          ),
          // Dark gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(60)],
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
          // Green plates available badge
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
              ),
              child: Text(
                '$platesAvailable PLATES AVAILABLE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String dishName, String price, String subtitle, List<String> ingredients, MessModel? mess, MenuItemModel? item) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dish name and price row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dishName,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  price,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Divider
            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 16),
            // What's Inside section
            if (ingredients.isNotEmpty) ...[
              Center(
                child: Text(
                  "WHAT'S INSIDE",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Ingredients grid (2 columns)
              _buildIngredientsGrid(ingredients),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 20),
            ],
            // Pickup Points & Timings
            _buildPickupSection(mess, item?.mealType.isNotEmpty == true ? item!.mealType.first : 'Extra'),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200, thickness: 1),
            const SizedBox(height: 16),
            // Auto Reorder toggle
            _buildAutoReorderRow(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsGrid(List<String> ingredients) {
    // Split ingredients into 2 columns
    final leftColumn = ingredients.whereIndexed((i, _) => i.isEven).toList();
    final rightColumn = ingredients.whereIndexed((i, _) => i.isOdd).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftColumn
                .map((item) => _buildIngredientItem(item))
                .toList(),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumn
                .map((item) => _buildIngredientItem(item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSection(MessModel? mess, String mealType) {
    if (mess == null) return const SizedBox.shrink();

    String timing = 'Open 24/7';
    bool isOpen = mess.isActive;

    if (mess.operatingHours != null && mess.operatingHours!.isNotEmpty) {
      final currentDay = DateFormat('EEEE').format(DateTime.now());
      final todayHours = mess.operatingHours!.firstWhere(
        (h) => h.day == currentDay,
        orElse: () => mess.operatingHours!.first,
      );
      isOpen = todayHours.isOpen;
      
      if (isOpen) {
        if (mealType == 'Breakfast' && todayHours.breakfast != null) {
          timing = '${todayHours.breakfast!.start} - ${todayHours.breakfast!.end}';
        } else if (mealType == 'Lunch' && todayHours.lunch != null) {
          timing = '${todayHours.lunch!.start} - ${todayHours.lunch!.end}';
        } else if (mealType == 'Dinner' && todayHours.dinner != null) {
          timing = '${todayHours.dinner!.start} - ${todayHours.dinner!.end}';
        } else {
           // Fallback to whichever is valid
           final start = todayHours.breakfast?.start ?? todayHours.lunch?.start ?? todayHours.dinner?.start;
           final end = todayHours.dinner?.end ?? todayHours.lunch?.end ?? todayHours.breakfast?.end;
           if (start != null && end != null) {
             timing = '$start - $end';
           } else {
             timing = 'Open';
           }
        }
      } else {
        timing = 'Closed Today';
      }
    }

    final List<Map<String, dynamic>> pickupPoints = [
      {
        'name': mess.name,
        'address': mess.address,
        'icon': Icons.storefront_outlined,
        'timing': timing,
        'isOpen': isOpen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pickup Points & Timings',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...pickupPoints.map((point) => _buildPickupCard(point)),
      ],
    );
  }

  Widget _buildPickupCard(Map<String, dynamic> point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  point['icon'] as IconData,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      point['address'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (point['isOpen'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'OPEN',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                point['timing'] as String,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutoReorderRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enable Auto Reorder',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Deliver this meal to me daily',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _autoReorder,
          onChanged: (val) => setState(() => _autoReorder = val),
          activeThumbColor: AppTheme.primary,
          inactiveThumbColor: Colors.grey.shade400,
          inactiveTrackColor: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildOrderButton(MenuItemModel? item, MessModel? mess) {
    // Check availability
    final bool isSoldOut = item != null && item.platesAvailable <= 0;
    final bool isUnavailable = item != null && !item.isAvailable;
    final bool canOrder = item != null && mess != null && !isSoldOut && !isUnavailable;

    String buttonLabel = 'Order Now';
    if (isSoldOut) buttonLabel = 'Sold Out';
    if (isUnavailable) buttonLabel = 'Not Available';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canOrder
              ? () {
                  final messId = mess.id;
                  final itemId = item.id ?? item.name;
                  if (messId == null || messId.isEmpty || itemId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open order page. Please refresh and try again.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    AppRoutes.orderMealPath(messId, itemId),
                    arguments: {
                      'item': item,
                      'mess': mess,
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canOrder ? AppTheme.primary : Colors.grey.shade400,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonLabel,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (canOrder) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

extension _IndexedWhere<T> on Iterable<T> {
  Iterable<T> whereIndexed(bool Function(int, T) test) sync* {
    var i = 0;
    for (final element in this) {
      if (test(i, element)) yield element;
      i++;
    }
  }
}
