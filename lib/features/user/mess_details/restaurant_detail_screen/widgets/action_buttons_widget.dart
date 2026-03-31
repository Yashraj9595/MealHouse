import 'package:google_fonts/google_fonts.dart';
import 'package:meal_house/core/app_export.dart';
import 'package:meal_house/features/mess_owner/domain/models/mess_model.dart';

class ActionButtonsWidget extends StatelessWidget {
  final bool isTablet;
  final MessModel mess;

  const ActionButtonsWidget({
    super.key,
    required this.isTablet,
    required this.mess,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ActionButton(
            icon: Icons.calendar_month_rounded,
            label: 'View Weekly Menu',
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.weeklyMenuScreen,
                arguments: mess,
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionButton(
            icon: Icons.notifications_rounded,
            label: 'Subscribe Weekly / Monthly',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _press,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
