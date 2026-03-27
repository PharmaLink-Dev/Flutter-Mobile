import 'package:flutter/material.dart';

// ============================================
// Constants
// ============================================
class HistoryConstants {
  static const Color primaryGreen = Color.fromRGBO(151, 255, 224, 1);
  static const Color darkGreen = Color.fromRGBO(100, 200, 170, 1);
}

// ============================================
// History Grouper
// ============================================
class HistoryGrouper {
  static List<Map<String, dynamic>> groupByTimeRange<T>(
    List<T> items,
    DateTime Function(T) getDate,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    final todayItems = <T>[];
    final yesterdayItems = <T>[];
    final lastWeekItems = <T>[];
    final lastMonthItems = <T>[];
    final olderItems = <T>[];

    for (final item in items) {
      final date = getDate(item);
      final itemDay = DateTime(date.year, date.month, date.day);

      if (itemDay.isAtSameMomentAs(today)) {
        todayItems.add(item);
      } else if (itemDay.isAtSameMomentAs(yesterday)) {
        yesterdayItems.add(item);
      } else if (itemDay.isAfter(lastWeek)) {
        lastWeekItems.add(item);
      } else if (itemDay.isAfter(lastMonth)) {
        lastMonthItems.add(item);
      } else {
        olderItems.add(item);
      }
    }

    final result = <Map<String, dynamic>>[];
    if (todayItems.isNotEmpty) {
      result.add({'title': 'TODAY', 'items': todayItems});
    }
    if (yesterdayItems.isNotEmpty) {
      result.add({'title': 'YESTERDAY', 'items': yesterdayItems});
    }
    if (lastWeekItems.isNotEmpty) {
      result.add({'title': 'LAST WEEK', 'items': lastWeekItems});
    }
    if (lastMonthItems.isNotEmpty) {
      result.add({'title': 'LAST MONTH', 'items': lastMonthItems});
    }
    if (olderItems.isNotEmpty) {
      result.add({'title': 'OLDER', 'items': olderItems});
    }

    return result;
  }
}

// ============================================
// Date Formatter
// ============================================
class DateFormatter {
  static String formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return _toShortString(date);
    }
  }

  static String _toShortString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
