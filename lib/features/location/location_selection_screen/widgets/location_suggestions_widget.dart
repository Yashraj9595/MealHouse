import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class LocationSuggestionsWidget extends StatelessWidget {
  final List<Map<String, String>> suggestions;
  final AnimationController listController;
  final ValueChanged<Map<String, String>> onSuggestionTap;
  final bool isTablet;

  const LocationSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.listController,
    required this.onSuggestionTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SUGGESTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                fontFamily: 'Outfit',
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: AppTheme.cardBorder)),
          ],
        ),
        const SizedBox(height: 16),
        if (suggestions.isEmpty)
          _buildEmptySearch()
        else if (isTablet)
          _buildTabletGrid()
        else
          _buildPhoneList(),
      ],
    );
  }

  Widget _buildPhoneList() {
    return Column(
      children: List.generate(suggestions.length, (i) {
        final delay = i * 80;
        return AnimatedBuilder(
          animation: listController,
          builder: (_, child) {
            final t = ((listController.value - delay / 500.0) / 0.6).clamp(
              0.0,
              1.0,
            );
            final curve = Curves.easeOutCubic.transform(t);
            return Opacity(
              opacity: curve,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - curve)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SuggestionCard(
              suggestion: suggestions[i],
              onTap: () => onSuggestionTap(suggestions[i]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTabletGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemCount: suggestions.length,
      itemBuilder: (_, i) => _SuggestionCard(
        suggestion: suggestions[i],
        onTap: () => onSuggestionTap(suggestions[i]),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppTheme.muted.withAlpha(128),
            ),
            const SizedBox(height: 12),
            const Text(
              'No locations found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try searching for another area in Pune',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.muted,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final Map<String, String> suggestion;
  final VoidCallback onTap;

  const _SuggestionCard({required this.suggestion, required this.onTap});

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tag = widget.suggestion['tag'] ?? '';
    final isCollege = tag == 'College';

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Gradient accent left border — LOCKED technique
          border: Border(
            left: BorderSide(
              color: isCollege ? AppTheme.primary : AppTheme.secondary,
              width: 3.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.03 : 0.06),
              blurRadius: _isPressed ? 6 : 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Location icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isCollege
                      ? AppTheme.primaryGradient
                      : const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.suggestion['name']!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Outfit',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isCollege
                                ? AppTheme.primary.withAlpha(26)
                                : AppTheme.secondary.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isCollege
                                  ? AppTheme.primaryDark
                                  : AppTheme.secondary,
                              fontFamily: 'Outfit',
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.suggestion['area']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
