import 'package:flutter/material.dart';
import 'package:meal_house/core/theme/app_theme.dart';

class LocationSearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const LocationSearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<LocationSearchBarWidget> createState() =>
      _LocationSearchBarWidgetState();
}

class _LocationSearchBarWidgetState extends State<LocationSearchBarWidget> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppTheme.primary : AppTheme.cardBorder,
          width: _isFocused ? 2 : 1.5,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(31),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppTheme.textPrimary,
          fontFamily: 'Outfit',
        ),
        decoration: InputDecoration(
          hintText: 'Search hostel, college, area...',
          hintStyle: TextStyle(
            color: AppTheme.muted,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.search_rounded,
              color: _isFocused ? AppTheme.primary : AppTheme.muted,
              size: 22,
            ),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.muted,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
