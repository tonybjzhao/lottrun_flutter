import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/generated_pick.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._();
  LocalStorageService._();
  static LocalStorageService get instance => _instance;

  static const _keyLotteryId = 'last_lottery_id';
  static const _keyStyle = 'last_style';
  static const _keyPick = 'last_pick';
  static const _keyStreakDate = 'streak_date';
  static const _keyStreakCount = 'streak_count';
  static const _keySavedPicks = 'saved_picks';

  Future<String?> getLastLotteryId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLotteryId);
  }

  Future<void> saveLastLotteryId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLotteryId, id);
  }

  Future<PlayStyle?> getLastStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyStyle);
    if (value == null) return null;
    return PlayStyle.values.firstWhere(
      (s) => s.name == value,
      orElse: () => PlayStyle.balanced,
    );
  }

  Future<void> saveLastStyle(PlayStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStyle, style.name);
  }

  Future<GeneratedPick?> getLastPick() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPick);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return GeneratedPick(
        lotteryId: map['lotteryId'] as String,
        style: PlayStyle.values.firstWhere(
          (s) => s.name == map['style'],
          orElse: () => PlayStyle.balanced,
        ),
        mainNumbers: List<int>.from(map['mainNumbers'] as List),
        bonusNumbers: map['bonusNumbers'] != null
            ? List<int>.from(map['bonusNumbers'] as List)
            : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Records today's open and returns the current streak count.
  /// Call once on app start.
  Future<int> recordDailyOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final last = prefs.getString(_keyStreakDate);
    final count = prefs.getInt(_keyStreakCount) ?? 0;

    if (last == today) return count; // already recorded today

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final newCount = (last == yesterday) ? count + 1 : 1;

    await prefs.setString(_keyStreakDate, today);
    await prefs.setInt(_keyStreakCount, newCount);
    return newCount;
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreakCount) ?? 0;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Saved picks list ────────────────────────────────────────────────────────

  static Map<String, dynamic> _pickToMap(GeneratedPick pick) => {
        'id': pick.id,
        'lotteryId': pick.lotteryId,
        'style': pick.style.name,
        'mainNumbers': pick.mainNumbers,
        'bonusNumbers': pick.bonusNumbers,
        'createdAt': pick.createdAt.toIso8601String(),
        'pickLabel': pick.pickLabel,
      };

  static GeneratedPick _pickFromMap(Map<String, dynamic> map) {
    final lotteryId = map['lotteryId'] as String;
    final createdAt = DateTime.parse(map['createdAt'] as String);
    return GeneratedPick(
      id: map['id'] as String? ??
          '${createdAt.millisecondsSinceEpoch}_${lotteryId.hashCode.abs()}',
      lotteryId: lotteryId,
      style: PlayStyle.values.firstWhere(
        (s) => s.name == map['style'],
        orElse: () => PlayStyle.balanced,
      ),
      mainNumbers: List<int>.from(map['mainNumbers'] as List),
      bonusNumbers: map['bonusNumbers'] != null
          ? List<int>.from(map['bonusNumbers'] as List)
          : null,
      createdAt: createdAt,
      pickLabel: map['pickLabel'] as String?,
    );
  }

  Future<List<GeneratedPick>> getSavedPicks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keySavedPicks) ?? [];
    final picks = <GeneratedPick>[];
    for (final s in raw) {
      try {
        picks.add(_pickFromMap(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    return picks;
  }

  Future<void> savePickToHistory(GeneratedPick pick) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keySavedPicks) ?? [];
    raw.insert(0, jsonEncode(_pickToMap(pick)));
    await prefs.setStringList(_keySavedPicks, raw);
  }

  Future<void> deleteSavedPickById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keySavedPicks) ?? [];
    raw.removeWhere((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return map['id'] == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_keySavedPicks, raw);
  }

  Future<void> clearSavedPicks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySavedPicks);
  }

  Future<void> saveLastPick(GeneratedPick pick) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'lotteryId': pick.lotteryId,
      'style': pick.style.name,
      'mainNumbers': pick.mainNumbers,
      'bonusNumbers': pick.bonusNumbers,
      'createdAt': pick.createdAt.toIso8601String(),
    };
    await prefs.setString(_keyPick, jsonEncode(map));
  }
}
