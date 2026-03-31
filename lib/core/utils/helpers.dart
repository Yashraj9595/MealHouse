import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount, {String currency = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }
  
  static String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(time);
  }
  
  static String formatDateTime(DateTime dateTime, {String format = 'dd MMM yyyy, hh:mm a'}) {
    return DateFormat(format).format(dateTime);
  }
  
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
  
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirstLetter(word)).join(' ');
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return email;
    
    final maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }
  
  static String maskPhoneNumber(String phone) {
    if (phone.length <= 4) return phone;
    
    final start = phone.substring(0, 2);
    final end = phone.substring(phone.length - 2);
    final middle = '*' * (phone.length - 4);
    
    return '$start$middle$end';
  }
  
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      case 'ready':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  static String getOrderStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Order Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready for Pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return capitalizeFirstLetter(status);
    }
  }
  
  static String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Payment Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Payment Successful';
      case 'failed':
        return 'Payment Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return capitalizeFirstLetter(status);
    }
  }
  
  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.red);
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, color: Colors.green);
  }
  
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  static String generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'ORD$timestamp$random';
  }
  
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  
  static List<String> splitString(String text, int chunkSize) {
    if (text.isEmpty) return [];
    
    final chunks = <String>[];
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    
    return chunks;
  }
  
  // Private constructor to prevent instantiation
  Helpers._();
}
