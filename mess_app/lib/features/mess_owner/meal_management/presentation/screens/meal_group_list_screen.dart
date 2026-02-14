import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MealHouse/core/app_export.dart';
import '../../domain/entities/meal_group_entity.dart';
import '../state/meal_providers.dart';
import '../widgets/meal_group_card.dart';
import './meal_item_edit_screen.dart';

class MealGroupListScreen extends ConsumerStatefulWidget {
  final String messId; 
  const MealGroupListScreen({super.key, required this.messId});

  @override
  ConsumerState<MealGroupListScreen> createState() => _MealGroupListScreenState();
}

class _MealGroupListScreenState extends ConsumerState<MealGroupListScreen> {
  MealType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealListAsync = ref.watch(mealListProvider(widget.messId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              "Meal Management",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textHeader,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                onPressed: () {
                  // Refresh action
                  ref.refresh(mealListProvider(widget.messId));
                },
                icon: const CustomIconWidget(iconName: 'refresh', color: AppColors.primary),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', null),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Breakfast', MealType.breakfast),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Lunch', MealType.lunch),
                    SizedBox(width: 2.w),
                    _buildFilterChip('Dinner', MealType.dinner),
                  ],
                ),
              ),
            ),
          ),
          mealListAsync.when(
            data: (meals) {
              final filteredMeals = _selectedFilter == null
                  ? meals
                  : meals.where((m) => m.mealType == _selectedFilter).toList();

              if (filteredMeals.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomIconWidget(
                          iconName: 'restaurant_menu',
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "No meals found",
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = filteredMeals[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: MealGroupCard(
                          group: group,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealItemEditScreen(group: group, messId: widget.messId),
                              ),
                            );
                          },
                          onToggleStatus: (val) async {
                            final useCase = ref.read(toggleMealStatusUseCaseProvider);
                            final result = await useCase(widget.messId, group.id, val);
                            result.fold(
                              (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.message))),
                              (r) => ref.refresh(mealListProvider(widget.messId)),
                            );
                          },
                        ),
                      );
                    },
                    childCount: filteredMeals.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meal_list_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealItemEditScreen(messId: widget.messId),
            ),
          );
        },
        label: const Text("Create New Meal", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buildFilterChip(String label, MealType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = selected ? type : null; // Toggle off if selected again, or explicit 'All' (null)
          if (type == null) _selectedFilter = null; // Ensure 'All' clears filter
        });
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textBody,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
    );
  }
}
