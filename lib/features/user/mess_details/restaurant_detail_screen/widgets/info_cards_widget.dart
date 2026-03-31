import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';
import 'package:intl/intl.dart';

class InfoCardsWidget extends StatelessWidget {
  final bool isTablet;
  final MessModel mess;

  const InfoCardsWidget({super.key, required this.isTablet, required this.mess});

  String _getHours() {
    if (mess.operatingHours == null || mess.operatingHours!.isEmpty) return 'Closed';
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final hours = mess.operatingHours!.firstWhere(
      (h) => h.day == currentDay,
      orElse: () => mess.operatingHours!.first,
    );
    if (!hours.isOpen) return 'Closed';

    final start = hours.breakfast?.start ?? hours.lunch?.start ?? hours.dinner?.start;
    final end = hours.dinner?.end ?? hours.lunch?.end ?? hours.breakfast?.end;
    
    if (start != null && end != null) return '$start - $end';
    return 'Open';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _InfoCard(
              icon: Icons.access_time_rounded,
              label: 'HOURS TODAY',
              value: _getHours(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoCard(
              icon: Icons.reviews_outlined,
              label: 'REVIEWS',
              value: '${mess.numReviews} Verified',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
