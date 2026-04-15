import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

import '../models/lottery.dart';
import '../models/lottery_draw.dart';

class LotteryHistoryCsvService {
  LotteryHistoryCsvService._();

  static final LotteryHistoryCsvService instance = LotteryHistoryCsvService._();

  static const Map<String, String> _csvUrls = {
    'au_ozlotto': 'https://tonybjzhao.github.io/lottrun_flutter/oz_lotto.csv',
    'au_saturday':
        'https://tonybjzhao.github.io/lottrun_flutter/saturday_lotto.csv',
    // Powerball can be added later once the public CSV is available.
  };

  Future<List<LotteryDraw>> fetchDraws(Lottery lottery) async {
    final baseUrl = _csvUrls[lottery.id];
    if (baseUrl == null) {
      throw Exception('No remote CSV configured for ${lottery.name}.');
    }

    final uri = Uri.parse(
      '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load history CSV (${response.statusCode}).');
    }

    final csvString = utf8.decode(response.bodyBytes);
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(csvString);

    if (rows.length <= 1) {
      throw Exception('History CSV is empty.');
    }

    try {
      final draws = rows
          .skip(1)
          .where((row) => row.length >= 3)
          .map((row) => _rowToDraw(row, lottery))
          .whereType<LotteryDraw>()
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
      final index = 10 + i;
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
