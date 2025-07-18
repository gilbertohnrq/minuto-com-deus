import 'package:intl/intl.dart';

class DateUtils {
  /// Formats a date to the Brazilian format (dd/MM/yyyy)
  static String formatDateBR(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Formats a date to ISO format (yyyy-MM-dd) for JSON matching
  static String formatDateISO(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Formats a date to display format (dd de MMMM de yyyy)
  static String formatDateDisplay(DateTime date) {
    return DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(date);
  }
  
  /// Gets today's date without time
  static DateTime get today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Checks if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Parses a date string in ISO format (yyyy-MM-dd)
  static DateTime? parseISODate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Gets the start of the day for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  /// Gets the end of the day for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  /// Checks if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, today);
  }
  
  /// Gets the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return (to.difference(from).inHours / 24).round();
  }
}