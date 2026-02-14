import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

/// Mess header widget displaying cover photo with overlay actions
class MessHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> messData;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onFavoritePressed;
  final bool isFavorite;

  const MessHeaderWidget({
    super.key,
    required this.messData,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onFavoritePressed,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 30.h,
      child: Stack(
        children: [
          CustomImageWidget(
            imageUrl: messData["coverImage"] as String,
            width: double.infinity,
            height: 30.h,
            fit: BoxFit.cover,
            semanticLabel: messData["coverImageLabel"] as String,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: onBackPressed,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: CustomIconWidget(
                                iconName: 'share',
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: onSharePressed,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: CustomIconWidget(
                                iconName: isFavorite
                                    ? 'favorite'
                                    : 'favorite_border',
                                color: isFavorite ? Colors.red : Colors.white,
                                size: 24,
                              ),
                              onPressed: onFavoritePressed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        messData["name"] as String,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  messData["rating"].toString(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            messData["cuisineType"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: (messData["isOpen"] as bool)
                                  ? Colors.green
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            (messData["isOpen"] as bool) ? "Open" : "Closed",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
