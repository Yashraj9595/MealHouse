import 'package:MealHouse/core/app_export.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> addresses = [
      {
        "type": "Home",
        "icon": AppIcons.home,
        "address": "House No. 42, 2nd Cross, Koramangala 4th Block, Bangalore - 560034",
        "isDefault": true,
      },
      {
        "type": "Work",
        "icon": AppIcons.work,
        "address": "Indiranagar Office Park, 5th Floor, Suite 502, Bangalore - 560038",
        "isDefault": false,
      },
      {
        "type": "Other",
        "icon": AppIcons.city,
        "address": "Greenwood Apartment, C-Wing, Whitefield, Bangalore - 560066",
        "isDefault": false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Addresses',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount: addresses.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final addr = addresses[index];
          return _buildAddressCard(theme, addr);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Add New Address'),
        icon: const CustomIconWidget(iconName: AppIcons.add),
      ),
    );
  }

  Widget _buildAddressCard(ThemeData theme, Map<String, dynamic> addr) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: addr["isDefault"] ? AppColors.primary : Colors.grey.shade200,
          width: addr["isDefault"] ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: addr["icon"] as String,
                    color: addr["isDefault"] ? AppColors.primary : Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    addr["type"] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: addr["isDefault"] ? AppColors.primary : AppColors.textHeader,
                    ),
                  ),
                ],
              ),
              if (addr["isDefault"] as bool)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            addr["address"] as String,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textBody,
              height: 1.4,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Edit'),
              ),
              SizedBox(width: 2.h),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
              const Spacer(),
              if (!(addr["isDefault"] as bool))
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Set as Default'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
