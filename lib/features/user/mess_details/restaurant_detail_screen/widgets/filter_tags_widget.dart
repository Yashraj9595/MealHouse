import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class FilterTagsWidget extends StatelessWidget {
  final MessModel mess;
  
  const FilterTagsWidget({super.key, required this.mess});

  @override
  Widget build(BuildContext context) {
    final tags = [
      _TagData(label: mess.cuisineType, isHighlighted: true),
      if (mess.isApproved) _TagData(label: 'Verified Mess', isHighlighted: false),
      _TagData(label: 'Homemade', isHighlighted: false),
      _TagData(label: 'Pure Veg', isHighlighted: false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: tags.map((tag) => _FilterChip(data: tag)).toList(),
      ),
    );
  }
}

class _TagData {
  final String label;
  final bool isHighlighted;
  const _TagData({required this.label, required this.isHighlighted});
}

class _FilterChip extends StatelessWidget {
  final _TagData data;
  const _FilterChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: data.isHighlighted ? AppTheme.primaryLight : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data.isHighlighted ? AppTheme.primary : AppTheme.outline,
          width: data.isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Text(
        data.label,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: data.isHighlighted ? FontWeight.w600 : FontWeight.w500,
          color: data.isHighlighted ? AppTheme.primary : AppTheme.onSurface,
        ),
      ),
    );
  }
}
