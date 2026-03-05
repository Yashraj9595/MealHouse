import 'package:MealHouse/core/app_export.dart';

/// Reviews section displaying rating breakdown and customer feedback
class ReviewsSectionWidget extends StatelessWidget {
  final Map<String, dynamic> messData;

  const ReviewsSectionWidget({super.key, required this.messData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = messData["reviews"] as List;
    final ratingBreakdown = messData["ratingBreakdown"] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            messData["rating"].toString(),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return CustomIconWidget(
                                iconName: index < messData["rating"].floor()
                                    ? 'star'
                                    : 'star_border',
                                color: theme.colorScheme.primary,
                                size: 20,
                              );
                            }),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            "${messData["totalReviews"]} reviews",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = ratingBreakdown["$star"] as int;
                            final total = messData["totalReviews"] as int;
                            final percentage = (count / total * 100).round();

                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: Row(
                                children: [
                                  Text(
                                    "$star",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  SizedBox(width: 2.w),
                                  CustomIconWidget(
                                    iconName: 'star',
                                    color: theme.colorScheme.primary,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor:
                                          theme.colorScheme.surface,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "$percentage%",
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text("Recent Reviews", style: theme.textTheme.titleMedium),
          SizedBox(height: 1.h),
          ...reviews.map((review) {
            final reviewMap = review as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: Text(
                            (reviewMap["userName"] as String)[0].toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviewMap["userName"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return CustomIconWidget(
                                      iconName:
                                          index < (reviewMap["rating"] as int)
                                          ? 'star'
                                          : 'star_border',
                                      color: theme.colorScheme.primary,
                                      size: 16,
                                    );
                                  }),
                                  SizedBox(width: 2.w),
                                  Text(
                                    reviewMap["date"] as String,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      reviewMap["comment"] as String,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
