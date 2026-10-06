import 'package:intl/intl.dart';

class AppDateUtils {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String getFormattedDate() {
    return DateFormat('EEEE, d MMM').format(DateTime.now());
  }
}

class NumberUtils {
  static String formatCompact(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toString();
  }
}
