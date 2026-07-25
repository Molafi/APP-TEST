import 'package:intl/intl.dart';

/// Locale- and timezone-aware date/time formatting. All formatting takes an
/// explicit locale so English and Arabic render correctly (including
/// Arabic-Indic digits where appropriate).
class DateFormatter {
  const DateFormatter._();

  static String time(DateTime dt, String locale) =>
      DateFormat.jm(locale).format(dt);

  static String shortDate(DateTime dt, String locale) =>
      DateFormat.MMMd(locale).format(dt);

  static String weekday(DateTime dt, String locale) =>
      DateFormat.E(locale).format(dt);

  static String dayAndDate(DateTime dt, String locale) =>
      DateFormat.MMMEd(locale).format(dt);

  static String messageTimestamp(DateTime dt, String locale) {
    final DateTime now = DateTime.now();
    final bool sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (sameDay) return DateFormat.jm(locale).format(dt);
    return DateFormat.MMMd(locale).add_jm().format(dt);
  }

  static String relativeUpdated(DateTime dt, String locale) {
    final Duration diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat.MMMd(locale).add_jm().format(dt);
  }
}
