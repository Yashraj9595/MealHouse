import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_house/core/constants/app_constants.dart';

enum TextFieldType {
  text,
  email,
  password,
  phone,
  number,
  multiline,
  search,
}

class CustomTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool showClearButton;
  final bool showPasswordToggle;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final String? Function(String?)? validator;
  final TextFieldType type;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? enabledBorder;
  final Color? fillColor;
  final Color? cursorColor;
  final bool filled;
  final BorderRadius? borderRadius;
  final double? height;

  const CustomTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onClear,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showClearButton = true,
    this.showPasswordToggle = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.validator,
    this.type = TextFieldType.text,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.enabledBorder,
    this.fillColor,
    this.cursorColor,
    this.filled = true,
    this.borderRadius,
    this.height,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: widget.height,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        obscureText: _obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        keyboardType: _getKeyboardType(),
        inputFormatters: _getInputFormatters(),
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onSubmitted,
        style: widget.textStyle ?? theme.textTheme.bodyMedium,
        cursorColor: widget.cursorColor ?? theme.primaryColor,
        decoration: _getInputDecoration(theme),
      ),
    );
  }

  InputDecoration _getInputDecoration(ThemeData theme) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
      borderSide: BorderSide(color: theme.dividerColor),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
      borderSide: BorderSide(color: theme.primaryColor, width: 2),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );

    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      contentPadding: widget.contentPadding ?? _getDefaultPadding(),
      filled: widget.filled,
      fillColor: widget.fillColor ?? theme.colorScheme.surface,
      border: widget.border ?? defaultBorder,
      focusedBorder: widget.focusedBorder ?? focusedBorder,
      errorBorder: widget.errorBorder ?? errorBorder,
      enabledBorder: widget.enabledBorder ?? defaultBorder,
      labelStyle: widget.labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      hintStyle: widget.hintStyle ?? theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      errorStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
      counterText: '', // Hide character counter
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    final icons = <Widget>[];
    
    // Add clear button
    if (widget.showClearButton && _hasText && widget.enabled && !widget.readOnly) {
      icons.add(
        IconButton(
          icon: const Icon(Icons.clear, size: 20),
          onPressed: _clearText,
          splashRadius: 20,
        ),
      );
    }
    
    // Add password toggle
    if (widget.showPasswordToggle && widget.type == TextFieldType.password) {
      icons.add(
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: _togglePasswordVisibility,
          splashRadius: 20,
        ),
      );
    }

    if (icons.isEmpty) return null;
    
    if (icons.length == 1) {
      return icons.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    if (widget.type == TextFieldType.multiline) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  TextInputType? _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;
    
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.password:
        return TextInputType.visiblePassword;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      case TextFieldType.search:
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) return widget.inputFormatters;
    
    switch (widget.type) {
      case TextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.email:
        return [FilteringTextInputFormatter.deny(RegExp(r'\s'))];
      default:
        return null;
    }
  }
}
