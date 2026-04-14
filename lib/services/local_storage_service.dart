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
