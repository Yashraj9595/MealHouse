import 'package:flutter/material.dart';

/// A notification that allows child screens to request a tab change
/// in the [MainNavigationWrapper].
class TabChangeNotification extends Notification {
  final int index;
  final dynamic args;

  const TabChangeNotification(this.index, {this.args});
}
