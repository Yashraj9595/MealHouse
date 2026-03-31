
extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
  
  bool get isThisYear {
    return year == DateTime.now().year;
  }
  
  DateTime get startOfDay => DateTime(year, month, day);
  
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }
  
  DateTime get endOfWeek {
    final daysToAdd = 7 - weekday;
    return add(Duration(days: daysToAdd)).endOfDay;
  }
  
  DateTime get startOfMonth => DateTime(year, month, 1);
  
  DateTime get endOfMonth {
    final nextMonth = month == 12 ? DateTime(year + 1, 1) : DateTime(year, month + 1);
    return nextMonth.subtract(const Duration(days: 1)).endOfDay;
  }
  
  DateTime get startOfYear => DateTime(year, 1, 1);
  
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
  
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else if (isThisYear) {
      return '${months[month - 1]} $day';
    } else {
      return '${months[month - 1]} $day, $year';
    }
  }
  
  String get formattedTime {
    final hour = this.hour;
    final minute = this.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
  
  String get formattedDateTime {
    if (isToday) {
      return formattedTime;
    } else {
      return '$formattedDate at $formattedTime';
    }
  }
  
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
  
  bool isSameWeek(DateTime other) {
    final startOfWeek1 = startOfWeek;
    final startOfWeek2 = other.startOfWeek;
    
    return startOfWeek1.isSameDay(startOfWeek2);
  }
  
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
  
  bool isSameYear(DateTime other) {
    return year == other.year;
  }
  
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }
  
  int get weekOfMonth {
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysDifference = difference(firstDayOfMonth).inDays;
    return (daysDifference / 7).floor() + 1;
  }
  
  DateTime addDays(int days) {
    return DateTime(year, month, day + days);
  }
  
  DateTime subtractDays(int days) {
    return DateTime(year, month, day - days);
  }
  
  DateTime addWeeks(int weeks) {
    return addDays(weeks * 7);
  }
  
  DateTime subtractWeeks(int weeks) {
    return subtractDays(weeks * 7);
  }
  
  DateTime addMonths(int months) {
    return DateTime(year + (month + months - 1) ~/ 12, (month + months - 1) % 12 + 1, day);
  }
  
  DateTime subtractMonths(int months) {
    return addMonths(-months);
  }
  
  DateTime addYears(int years) {
    return DateTime(year + years, month, day);
  }
  
  DateTime subtractYears(int years) {
    return addYears(-years);
  }
  
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }
  
  bool isOnOrAfter(DateTime date) {
    return isAtSameMomentAs(date) || isAfter(date);
  }
  
  bool isOnOrBefore(DateTime date) {
    return isAtSameMomentAs(date) || isBefore(date);
  }
  
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    
    return age;
  }
  
  String get relativeDate {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (isToday) {
      return 'Today';
    } else if (isYesterday) {
      return 'Yesterday';
    } else if (isTomorrow) {
      return 'Tomorrow';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
