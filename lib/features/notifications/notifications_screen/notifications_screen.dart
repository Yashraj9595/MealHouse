import 'package:meal_house/core/app_export.dart';
import './widgets/notification_filter_widget.dart';
import './widgets/notification_list_widget.dart';
import './widgets/notifications_app_bar_widget.dart';
import './widgets/notifications_bottom_nav_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0; // 0=All, 1=Orders, 2=Subscriptions, 3=Wallet
  int _selectedNavIndex = 2; // Subscriptions active (index 2 in 5-item nav)

  // TODO: Replace with Riverpod/Bloc for production state management
  final List<Map<String, dynamic>> _notificationMaps = [
    {
      'id': '1',
      'type': 'order',
      'title': 'Order Delivered!',
      'body':
          'Your lunch tiffin (Aloo Paratha & Curd) has been delivered. Enjoy your meal!',
      'timestamp': '2m ago',
      'isUnread': true,
      'iconKey': 'delivery',
    },
    {
      'id': '2',
      'type': 'subscription',
      'title': 'Subscription Renewed',
      'body':
          'Your monthly dinner subscription has been successfully renewed for May.',
      'timestamp': '1h ago',
      'isUnread': true,
      'iconKey': 'subscription',
    },
    {
      'id': 'wallet_alert',
      'type': 'wallet',
      'title': 'Low Wallet Balance',
      'body':
          'Your wallet balance is low (₹45 remaining). Please recharge to continue auto orders.',
      'timestamp': '2h ago',
      'isUnread': true,
      'iconKey': 'wallet_alert',
    },
    {
      'id': '3',
      'type': 'wallet',
      'title': 'Refund Processed',
      'body':
          'Refund of ₹120 for Order #8291 has been added to your Tiffin Wallet.',
      'timestamp': '4h ago',
      'isUnread': false,
      'iconKey': 'wallet',
    },
    {
      'id': '4',
      'type': 'order',
      'title': 'Holiday Notice',
      'body':
          'The mess will remain closed on Sunday, May 12th for maintenance. Plan accordingly!',
      'timestamp': 'Yesterday',
      'isUnread': false,
      'iconKey': 'announcement',
    },
    {
      'id': '5',
      'type': 'subscription',
      'title': 'Special Sunday Feast!',
      'body':
          "Book your 'Executive Sunday Thali' now and get a free Gulab Jamun dessert.",
      'timestamp': '2 days ago',
      'isUnread': false,
      'iconKey': 'promo',
    },
  ];

  late List<Map<String, dynamic>> _notifications;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    // TODO: Replace with Riverpod/Bloc for production state management
    _notifications = List<Map<String, dynamic>>.from(_notificationMaps);
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 0) return _notifications;
    final filterMap = {1: 'order', 2: 'subscription', 3: 'wallet'};
    final filterType = filterMap[_selectedFilter];
    return _notifications.where((n) => n['type'] == filterType).toList();
  }

  int get _unreadCount =>
      _notifications.where((n) => n['isUnread'] == true).length;

  void _onFilterChanged(int index) {
    // TODO: Replace with Riverpod/Bloc for production state management
    setState(() {
      _selectedFilter = index;
    });
    _listAnimationController.reset();
    _listAnimationController.forward();
  }

  void _markAllAsRead() {
    // TODO: Replace with Riverpod/Bloc for production state management
    setState(() {
      for (final n in _notifications) {
        n['isUnread'] = false;
      }
    });
  }

  void _markAsRead(String id) {
    // TODO: Replace with Riverpod/Bloc for production state management
    setState(() {
      final idx = _notifications.indexWhere((n) => n['id'] == id);
      if (idx != -1) _notifications[idx]['isUnread'] = false;
    });
  }

  void _deleteNotification(String id) {
    // TODO: Replace with Riverpod/Bloc for production state management
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _onNavTap(int index) {
    // TODO: Replace with Riverpod/Bloc for production state management
    setState(() => _selectedNavIndex = index);
  }

  void _onSettingsTap() {
    Navigator.of(context).pushNamed(AppRoutes.notificationSettingsScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationsAppBarWidget(
                  onSettingsTap: _onSettingsTap,
                  onBackTap: () => Navigator.of(context).maybePop(),
                ),
                SizedBox(height: 1.5.h),
                NotificationFilterWidget(
                  selectedIndex: _selectedFilter,
                  onFilterChanged: _onFilterChanged,
                ),
                SizedBox(height: 1.5.h),
                Expanded(
                  child: NotificationListWidget(
                    notifications: _filteredNotifications,
                    animationController: _listAnimationController,
                    onMarkAllRead: _markAllAsRead,
                    onMarkRead: _markAsRead,
                    onDelete: _deleteNotification,
                    hasUnread: _unreadCount > 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NotificationsBottomNavWidget(
        selectedIndex: _selectedNavIndex,
        unreadAlertCount: _unreadCount,
        onTap: _onNavTap,
      ),
    );
  }
}
