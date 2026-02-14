class MealItemEntity {
  final String id;
  final String name;
  final String? description;
  final bool isAvailable;

  MealItemEntity({
    required this.id,
    required this.name,
    this.description,
    this.isAvailable = true,
  });
}
