import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/generated/app_localizations_en.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../models/lottery_history_result.dart';
import 'lottery_service.dart';

final _l10n = AppLocalizationsEn();

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
    'uk_lotto': 'https://tonybjzhao.github.io/lottrun_flutter/uk_lotto.csv',
    'uk_euromillions':
        'https://tonybjzhao.github.io/lottrun_flutter/uk_euromillions.csv',
    'ca_lotto_max':
        'https://tonybjzhao.github.io/lottrun_flutter/ca_lotto_max.csv',
    'ca_lotto_649':
        'https://tonybjzhao.github.io/lottrun_flutter/ca_lotto_649.csv',
    'de_lotto_6aus49':
        'https://tonybjzhao.github.io/lottrun_flutter/de_lotto_6aus49.csv',
    'de_eurojackpot':
        'https://tonybjzhao.github.io/lottrun_flutter/de_eurojackpot.csv',
    'jp_loto6': 'https://tonybjzhao.github.io/lottrun_flutter/jp_loto6.csv',
    'jp_loto7': 'https://tonybjzhao.github.io/lottrun_flutter/jp_loto7.csv',
    'fr_loto': 'https://tonybjzhao.github.io/lottrun_flutter/fr_loto.csv',
    'fr_euromillions':
        'https://tonybjzhao.github.io/lottrun_flutter/fr_euromillions.csv',
  };

  static const Map<String, String> _cacheKeys = {
    'au_powerball': 'cache_powerball_csv',
    'au_ozlotto': 'cache_oz_lotto_csv',
    'au_saturday': 'cache_saturday_lotto_csv',
    'us_powerball': 'cache_us_powerball_csv',
    'us_megamillions': 'cache_us_megamillions_csv',
    'uk_lotto': 'cache_uk_lotto_csv',
    'uk_euromillions': 'cache_uk_euromillions_csv',
    'ca_lotto_max': 'cache_ca_lotto_max_csv',
    'ca_lotto_649': 'cache_ca_lotto_649_csv',
    'de_lotto_6aus49': 'cache_de_lotto_6aus49_csv',
    'de_eurojackpot': 'cache_de_eurojackpot_csv',
    'jp_loto6': 'cache_jp_loto6_csv',
    'jp_loto7': 'cache_jp_loto7_csv',
    'fr_loto': 'cache_fr_loto_csv',
    'fr_euromillions': 'cache_fr_euromillions_csv',
  };

  Future<LotteryHistoryResult> fetchDraws(Lottery lottery) async {
    final baseUrl = _csvUrls[lottery.id];
    if (baseUrl == null) {
      final seedDraws = LotteryService.instance.getDraws(lottery.id);
      if (seedDraws.isNotEmpty) {
        return LotteryHistoryResult(
          draws: seedDraws,
          source: LotteryHistorySource.seed,
          loadedAt: null,
        );
      }
      throw Exception(_l10n.lotteryHistoryNoRemoteCsv(lottery.name));
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKeys[lottery.id];
    final updatedAtKey = cacheKey == null ? null : '${cacheKey}_updated_at';
    try {
      final uri = Uri.parse(
        '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw Exception(_l10n.lotteryHistoryLoadFailed(response.statusCode));
      }

      final csvString = utf8.decode(response.bodyBytes);
      final draws = _mergeWithSeedDraws(_parseDraws(csvString, lottery));

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
          final draws = _mergeWithSeedDraws(_parseDraws(cachedCsv, lottery));
          final loadedAtText = prefs.getString(updatedAtKey!);
          return LotteryHistoryResult(
            draws: draws,
            source: LotteryHistorySource.cache,
            loadedAt: loadedAtText == null
                ? null
                : DateTime.tryParse(loadedAtText),
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
          source: LotteryHistorySource.seed,
          loadedAt: null,
        );
      }

      throw Exception(_l10n.noInternetNoSavedHistory);
    }
  }

  List<LotteryDraw> _parseDraws(String csvString, Lottery lottery) {
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvString);

    if (rows.length <= 1) {
      throw Exception(_l10n.lotteryHistoryCsvEmpty);
    }

    try {
      final header = rows.first.map((cell) => cell.toString().trim()).toList();
      final normalizedHeader = header
          .map((cell) => cell.toLowerCase())
          .toList();
      final dateIndex = normalizedHeader.indexWhere(
        (cell) => cell == 'draw_date' || cell == 'date',
      );
      final roundIndex = header.indexWhere((cell) {
        final normalized = cell.toLowerCase();
        return normalized == 'round' || normalized == 'draw_number';
      });
      final mainIndices = _numberColumnIndices(
        normalizedHeader,
        'main_',
        lottery.mainCount,
      );
      final bonusIndices = _bonusColumnIndices(
        normalizedHeader,
        lottery.bonusCount ?? 0,
      );
      final fallbackFirstMainIndex = roundIndex >= 0 ? roundIndex + 1 : 3;
      final seen = <String>{};
      final draws =
          rows
              .skip(1)
              .where((row) => row.length >= 3)
              .map(
                (row) => _rowToDraw(
                  row,
                  lottery,
                  dateIndex: dateIndex >= 0 ? dateIndex : 1,
                  mainIndices: mainIndices,
                  bonusIndices: bonusIndices,
                  fallbackFirstMainIndex: fallbackFirstMainIndex,
                  roundIndex: roundIndex,
                ),
              )
              .whereType<LotteryDraw>()
              .where((draw) {
                final key =
                    '${draw.drawDate.toIso8601String()}-${draw.mainNumbers.join(',')}-${(draw.bonusNumbers ?? []).join(',')}';
                return seen.add(key);
              })
              .toList()
            ..sort((a, b) => b.drawDate.compareTo(a.drawDate));

      if (draws.isEmpty) {
        throw Exception(_l10n.lotteryHistoryNoValidRows);
      }

      return draws;
    } catch (error) {
      throw Exception(_l10n.lotteryHistoryParseFailed(error.toString()));
    }
  }

  List<LotteryDraw> _mergeWithSeedDraws(List<LotteryDraw> remoteDraws) {
    final seedDraws = LotteryService.instance.getDraws(
      remoteDraws.first.lotteryId,
    );
    if (seedDraws.isEmpty) return remoteDraws;

    final seen = <String>{};
    final merged = <LotteryDraw>[];
    for (final draw in [...remoteDraws, ...seedDraws]) {
      final key =
          '${draw.drawDate.toIso8601String()}-${draw.mainNumbers.join(',')}-${(draw.bonusNumbers ?? []).join(',')}';
      if (seen.add(key)) {
        merged.add(draw);
      }
    }

    return merged..sort((a, b) => b.drawDate.compareTo(a.drawDate));
  }

  List<int> _numberColumnIndices(
    List<String> header,
    String prefix,
    int count,
  ) {
    return List.generate(count, (index) {
      return header.indexWhere((cell) => cell == '$prefix${index + 1}');
    }).where((index) => index >= 0).toList();
  }

  List<int> _bonusColumnIndices(List<String> header, int count) {
    if (count <= 0) return const [];

    final bonusIndices = _numberColumnIndices(header, 'bonus_', count);
    if (bonusIndices.length == count) return bonusIndices;

    final suppIndices = _numberColumnIndices(header, 'supp_', count);
    if (suppIndices.length == count) return suppIndices;

    return bonusIndices.isNotEmpty ? bonusIndices : suppIndices;
  }

  LotteryDraw? _rowToDraw(
    List<dynamic> row,
    Lottery lottery, {
    required int dateIndex,
    required List<int> mainIndices,
    required List<int> bonusIndices,
    required int fallbackFirstMainIndex,
    required int roundIndex,
  }) {
    final drawDateText = _cell(row, dateIndex);
    if (drawDateText.isEmpty) return null;

    final drawDate = DateTime.tryParse(drawDateText);
    if (drawDate == null) return null;

    final drawRound = roundIndex >= 0 && roundIndex < row.length
        ? int.tryParse(row[roundIndex]?.toString().trim() ?? '') ?? 1
        : 1;

    final mainNumbers = <int>[];
    final resolvedMainIndices = mainIndices.length == lottery.mainCount
        ? mainIndices
        : List.generate(lottery.mainCount, (i) => fallbackFirstMainIndex + i);
    for (final index in resolvedMainIndices) {
      final value = _cell(row, index);
      if (value.isEmpty) continue;
      final parsed = int.tryParse(value);
      if (parsed != null) mainNumbers.add(parsed);
    }

    final bonusNumbers = <int>[];
    final bonusCount = lottery.bonusCount ?? 0;
    final resolvedBonusIndices = bonusIndices.length == bonusCount
        ? bonusIndices
        : List.generate(
            bonusCount,
            (i) => fallbackFirstMainIndex + lottery.mainCount + i,
          );
    for (final index in resolvedBonusIndices) {
      final value = _cell(row, index);
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
      drawRound: drawRound,
    );
  }

  String _cell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return row[index]?.toString().trim() ?? '';
  }
}
