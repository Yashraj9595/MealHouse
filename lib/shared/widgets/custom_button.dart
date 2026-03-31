import 'package:flutter/material.dart';
import 'package:meal_house/core/constants/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
  warning,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderSide,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get button style based on type
    final buttonStyle = _getButtonStyle(theme);
    
    // Get button size
    final buttonSize = _getButtonSize();
    
    // Build button content
    final buttonContent = child ?? _buildButtonContent();
    
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? buttonSize.height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: buttonContent,
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: _getLoadingSize(),
        width: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getTextColor(),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle(),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: color ?? theme.colorScheme.secondary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.outline:
        return OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color ?? theme.primaryColor,
          side: borderSide ?? BorderSide(color: color ?? theme.primaryColor),
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.text:
        return TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: color ?? theme.primaryColor,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.success:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
      
      case ButtonType.warning:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          padding: padding ?? _getDefaultPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        );
    }
  }

  ButtonSizeData _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return ButtonSizeData(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          fontSize: 12,
        );
      case ButtonSize.medium:
        return ButtonSizeData(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          fontSize: 14,
        );
      case ButtonSize.large:
        return ButtonSizeData(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          fontSize: 16,
        );
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    return _getButtonSize().padding;
  }

  TextStyle _getTextStyle() {
    final buttonSize = _getButtonSize();
    return textStyle?.copyWith(fontSize: buttonSize.fontSize) ??
        TextStyle(
          fontSize: buttonSize.fontSize,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        );
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    
    switch (type) {
      case ButtonType.outline:
      case ButtonType.text:
        return color ?? Theme.of(Get.context!).primaryColor;
      default:
        return Colors.white;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

class ButtonSizeData {
  final double height;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const ButtonSizeData({
    required this.height,
    required this.padding,
    required this.fontSize,
  });
}

// Extension to get context
extension Get on CustomButton {
  static BuildContext? _context;
  
  static BuildContext? get context => _context;
  
  static void setContext(BuildContext context) {
    _context = context;
  }
}
