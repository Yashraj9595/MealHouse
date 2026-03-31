extension StringExtensions on String {
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  bool get isPhoneNumber => RegExp(r'^[\d\s\-\+\(\)]+$').hasMatch(this);
  
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);
  
  bool get isAlphabetic => RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  
  bool get isEmptyOrWhitespace => trim().isEmpty;
  
  bool get isNotBlank => trim().isNotEmpty;
  
  bool get isBlank => trim().isEmpty;
  
  String get capitalize => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  
  String get capitalizeWords => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize)
      .join(' ');
  
  String get titleCase => split(' ')
      .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
  
  String get removeAllWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  String get removeExtraWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');
  
  String get toCamelCase {
    final parts = split(' ');
    if (parts.isEmpty) return this;
    
    return parts[0].toLowerCase() +
        parts.skip(1).map((part) => part.capitalize).join('');
  }
  
  String get toSnakeCase {
    final res = replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    return res.startsWith('_') ? res.substring(1) : res;
  }
  
  String get toKebabCase => toSnakeCase.replaceAll('_', '-');
  
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
  
  String maskEmail() {
    final parts = split('@');
    if (parts.length != 2) return this;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) return this;
    
    final maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }
  
  String maskPhoneNumber() {
    if (length <= 4) return this;
    
    final start = substring(0, 2);
    final end = substring(length - 2);
    final middle = '*' * (length - 4);
    
    return '$start$middle$end';
  }
  
  String maskCreditCard() {
    final cleaned = removeAllWhitespace;
    if (cleaned.length < 4) return this;
    
    final lastFour = cleaned.substring(cleaned.length - 4);
    final masked = '*' * (cleaned.length - 4);
    
    return '$masked$lastFour';
  }
  
  String removeHtmlTags() => replaceAll(RegExp(r'<[^>]*>'), '');
  
  String get initials {
    final words = split(' ').where((word) => word.isNotEmpty);
    if (words.isEmpty) return '';
    
    return words.map((word) => word[0].toUpperCase()).take(2).join('');
  }
  
  String get firstWords {
    final words = split(' ').take(3).join(' ');
    return words.length < length ? '$words...' : this;
  }
  
  bool containsIgnoreCase(String other) => toLowerCase().contains(other.toLowerCase());
  
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
  
  String get reverse => split('').reversed.join('');
  
  int get wordCount => split(' ').where((word) => word.isNotEmpty).length;
  
  bool get isPalindrome {
    final cleaned = removeAllWhitespace.toLowerCase();
    return cleaned == cleaned.reverse;
  }
  
  String repeat(int times) => List.filled(times, this).join('');
  
  String padLeftWithZeros(int width) => padLeft(width, '0');
  
  String padRightWithZeros(int width) => padRight(width, '0');
  
  String get removeDiacritics {
    const diacritics = 'áàâäãåāăąçćčđďèéêëēėęěğǵḧîïíīįìłḿñńǹňôöòóœøōõőṕŕřßśšşșťțûüùúūǘůűųẃẍÿýžźż·/_,:;';
    const replacements = 'aaaaaaaaaacccddeeeeeeeegghiiiiiilmnnnnoooooooooprrsssssttuuuuuuuuuwxyyzzz------';
    
    var result = toLowerCase();
    for (int i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacements[i]);
    }
    
    return result.replaceAll(RegExp(r'[^a-z0-9 -]'), '');
  }
  
  String get slugify => toSnakeCase.replaceAll(RegExp(r'[^\w\-]+'), '');
  
  String escapeRegExp() => replaceAll(RegExp(r'([.*+?^=!:${}()|\[\]\/\\])'), r'\$1');
}
