import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:MealHouse/core/app_export.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final double? opacity;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.opacity,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? Container(
        width: width,
        height: height,
        color: theme.colorScheme.surfaceVariant,
        child: Center(
          child: CustomIconWidget(
            iconName: 'restaurant',
            color: theme.colorScheme.onSurfaceVariant,
            size: 40,
          ),
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? Container(
        width: width,
        height: height,
        color: theme.colorScheme.surfaceVariant,
        child: Center(
          child: CustomIconWidget(
            iconName: 'broken_image',
            color: theme.colorScheme.onSurfaceVariant,
            size: 40,
          ),
        ),
      ),
    );
    
    if (opacity != null) {
      return Opacity(
        opacity: opacity!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
}
