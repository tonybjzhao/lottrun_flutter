import 'package:intl/intl.dart';

/// Returns the next upcoming draw date (UTC midnight) for [lotteryId].
/// Returns null for unknown lotteries.
DateTime? nextDrawDate(String lotteryId) {
  final auWeekday = switch (lotteryId) {
    'au_powerball' => DateTime.thursday,
    'au_ozlotto'   => DateTime.tuesday,
    'au_saturday'  => DateTime.saturday,
    _              => null,
  };
  if (auWeekday != null) {
    final now = DateTime.now().toUtc().add(const Duration(hours: 10)); // AEST
    var next = now;
    while (next.weekday != auWeekday) {
      next = next.add(const Duration(days: 1));
    }
    if (next.day == now.day &&
        (now.hour > 20 || (now.hour == 20 && now.minute >= 30))) {
      next = next.add(const Duration(days: 7));
    }
    return DateTime.utc(next.year, next.month, next.day);
  }

  final usDrawDays = switch (lotteryId) {
    'us_powerball'    => [DateTime.monday, DateTime.wednesday, DateTime.saturday],
    'us_megamillions' => [DateTime.tuesday, DateTime.friday],
    _                 => null,
  };
  if (usDrawDays != null) {
    final now = DateTime.now().toUtc().subtract(const Duration(hours: 5)); // ET
    DateTime? nearest;
    for (final weekday in usDrawDays) {
      var candidate = now;
      while (candidate.weekday != weekday) {
        candidate = candidate.add(const Duration(days: 1));
      }
      if (candidate.day == now.day &&
          (now.hour > 22 || (now.hour == 22 && now.minute >= 59))) {
        candidate = candidate.add(const Duration(days: 7));
      }
      if (nearest == null || candidate.isBefore(nearest)) {
        nearest = candidate;
      }
    }
    if (nearest != null) {
      return DateTime.utc(nearest.year, nearest.month, nearest.day);
    }
  }

  return null;
}

/// Returns a human-readable label for the next draw, e.g. "Thu 17 Apr".
String? nextDrawLabel(String lotteryId) {
  final date = nextDrawDate(lotteryId);
  if (date == null) return null;
  return DateFormat('EEE d MMM').format(date.toLocal());
}
