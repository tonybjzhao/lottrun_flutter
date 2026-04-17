import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../models/lottery_history_result.dart';
import 'lottery_service.dart';

class LotteryHistoryCsvService {
  LotteryHistoryCsvService._();

  static final LotteryHistoryCsvService instance = LotteryHistoryCsvService._();

  static const Map<String, String> _csvUrls = {
    'au_powerball':
        'https://tonybjzhao.github.io/lottrun_flutter/powerball.csv',
    'au_ozlotto': 'https://tonybjzhao.github.io/lottrun_flutter/oz_lotto.csv',
    'au_saturday':
        'https://tonybjzhao.github.io/lottrun_flutter/saturday_lotto.csv',
    'us_powerball':
        'https://tonybjzhao.github.io/lottrun_flutter/us_powerball.csv',
    'us_megamillions':
        'https://tonybjzhao.github.io/lottrun_flutter/us_megamillions.csv',
  };

  static const Map<String, String> _cacheKeys = {
    'au_powerball': 'cache_powerball_csv',
    'au_ozlotto': 'cache_oz_lotto_csv',
    'au_saturday': 'cache_saturday_lotto_csv',
    'us_powerball': 'cache_us_powerball_csv',
    'us_megamillions': 'cache_us_megamillions_csv',
  };

  Future<LotteryHistoryResult> fetchDraws(Lottery lottery) async {
    final baseUrl = _csvUrls[lottery.id];
    if (baseUrl == null) {
      throw Exception('No remote CSV configured for ${lottery.name}.');
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKeys[lottery.id];
    final updatedAtKey = cacheKey == null ? null : '${cacheKey}_updated_at';
    try {
      final uri = Uri.parse(
        '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception('Failed to load history CSV (${response.statusCode}).');
      }

      final csvString = utf8.decode(response.bodyBytes);
      final draws = _parseDraws(csvString, lottery);

      if (cacheKey != null) {
        await prefs.setString(cacheKey, csvString);
        await prefs.setString(updatedAtKey!, DateTime.now().toIso8601String());
      }

      return LotteryHistoryResult(
        draws: draws,
        source: LotteryHistorySource.network,
        loadedAt: DateTime.now(),
      );
    } catch (_) {
      if (cacheKey == null) {
        rethrow;
      }

      final cachedCsv = prefs.getString(cacheKey);
      if (cachedCsv != null && cachedCsv.trim().isNotEmpty) {
        try {
          final draws = _parseDraws(cachedCsv, lottery);
          final loadedAtText = prefs.getString(updatedAtKey!);
          return LotteryHistoryResult(
            draws: draws,
            source: LotteryHistorySource.cache,
            loadedAt: loadedAtText == null ? null : DateTime.tryParse(loadedAtText),
          );
        } catch (_) {
          // cached CSV corrupt — fall through to seed data
        }
      }

      // No network, no cache — fall back to bundled seed draws
      final seedDraws = LotteryService.instance.getDraws(lottery.id);
      if (seedDraws.isNotEmpty) {
        return LotteryHistoryResult(
          draws: seedDraws,
          source: LotteryHistorySource.cache,
          loadedAt: null,
        );
      }

      throw Exception('No internet connection and no saved lottery history yet.');
    }
  }

  List<LotteryDraw> _parseDraws(String csvString, Lottery lottery) {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvString);

    if (rows.length <= 1) {
      throw Exception('History CSV is empty.');
    }

    try {
      final seen = <String>{};
      final draws = rows
          .skip(1)
          .where((row) => row.length >= 3)
          .map((row) => _rowToDraw(row, lottery))
          .whereType<LotteryDraw>()
          .where((draw) {
            final key =
                '${draw.drawDate.toIso8601String()}-${draw.mainNumbers.join(',')}-${(draw.bonusNumbers ?? []).join(',')}';
            return seen.add(key);
          })
          .toList()
        ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

      if (draws.isEmpty) {
        throw Exception('No valid draw rows found in CSV.');
      }

      return draws;
    } catch (error) {
      throw Exception('Failed to parse history CSV: $error');
    }
  }

  LotteryDraw? _rowToDraw(List<dynamic> row, Lottery lottery) {
    final drawDateText = row[1]?.toString().trim() ?? '';
    if (drawDateText.isEmpty) return null;

    final drawDate = DateTime.tryParse(drawDateText);
    if (drawDate == null) return null;

    final mainNumbers = <int>[];
    for (var i = 0; i < lottery.mainCount; i++) {
      final index = 3 + i;
      if (index >= row.length) break;
      final value = row[index]?.toString().trim() ?? '';
      if (value.isEmpty) continue;
      final parsed = int.tryParse(value);
      if (parsed != null) mainNumbers.add(parsed);
    }

    final bonusNumbers = <int>[];
    final bonusCount = lottery.bonusCount ?? 0;
    for (var i = 0; i < bonusCount; i++) {
      final index = 3 + lottery.mainCount + i;
      if (index >= row.length) break;
      final value = row[index]?.toString().trim() ?? '';
      if (value.isEmpty) continue;
      final parsed = int.tryParse(value);
      if (parsed != null) bonusNumbers.add(parsed);
    }

    if (mainNumbers.length != lottery.mainCount) {
      return null;
    }

    return LotteryDraw(
      lotteryId: lottery.id,
      drawDate: drawDate,
      mainNumbers: mainNumbers,
      bonusNumbers: bonusNumbers.isEmpty ? null : bonusNumbers,
    );
  }
}
