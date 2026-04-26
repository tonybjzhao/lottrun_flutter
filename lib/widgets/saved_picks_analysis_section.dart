import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/generated_pick.dart';
import '../models/lottery_draw.dart';
import '../services/draw_analysis_service.dart';

class SavedPicksAnalysisSection extends StatelessWidget {
  final List<GeneratedPick> picks;
  final Map<String, List<LotteryDraw>> drawsByLottery;

  const SavedPicksAnalysisSection({
    super.key,
    required this.picks,
    required this.drawsByLottery,
  });

  SavedPicksAnalysis _compute() {
    // Collect all main number lists from saved picks
    final allMainNumbers = picks.map((p) => p.mainNumbers).toList();

    // Use draws from the first lottery that has data (cross-lottery comparison
    // is not meaningful, so we use the most common lottery among saved picks)
    final lotteryFreq = <String, int>{};
    for (final p in picks) {
      lotteryFreq[p.lotteryId] = (lotteryFreq[p.lotteryId] ?? 0) + 1;
    }
    if (lotteryFreq.isEmpty) {
      return DrawAnalysisService.analyzeSavedPicks(
        savedMainNumbers: [],
        recentDraws: [],
      );
    }
    final dominantId =
        lotteryFreq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    final recentDraws = drawsByLottery[dominantId] ?? [];

    // Only include picks for the dominant lottery in the analysis
    final filteredMains = picks
        .where((p) => p.lotteryId == dominantId)
        .map((p) => p.mainNumbers)
        .toList();

    return DrawAnalysisService.analyzeSavedPicks(
      savedMainNumbers: filteredMains.isNotEmpty ? filteredMains : allMainNumbers,
      recentDraws: recentDraws,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = _compute();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Text(
            'My Saved Picks Analysis',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Compared with recent 20 draws · post-draw analysis only',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(120),
            ),
          ),

          const SizedBox(height: 12),

          // ── Stats row ────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                label: 'Best match',
                value: analysis.bestMatchCount > 0
                    ? '${analysis.bestMatchCount} numbers'
                    : '—',
                sub: analysis.bestMatchDrawDate != null
                    ? _formatDate(analysis.bestMatchDrawDate!)
                    : null,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Avg match',
                value: analysis.averageMatchCount > 0
                    ? analysis.averageMatchCount.toStringAsFixed(1)
                    : '—',
                sub: 'per draw',
                theme: theme,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Frequently picked numbers ────────────────────────────
          if (analysis.frequentlyPickedNumbers.isNotEmpty) ...[
            _MetricRow(
              label: 'Often picked',
              child: _NumberChips(
                numbers: analysis.frequentlyPickedNumbers,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ── Recently appeared ────────────────────────────────────
          if (analysis.recentlyAppearedNumbers.isNotEmpty) ...[
            _MetricRow(
              label: 'In recent draws',
              child: _NumberChips(
                numbers: analysis.recentlyAppearedNumbers.take(8).toList(),
                color: Colors.teal.shade600,
                theme: theme,
              ),
            ),
            const SizedBox(height: 10),
          ],

          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Summary ──────────────────────────────────────────────
          _SummaryText(
            en: analysis.summaryEn,
            zh: analysis.summaryZh,
            theme: theme,
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d MMM yy').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.theme,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (sub != null)
              Text(
                sub!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(100),
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Metric row ────────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _MetricRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ── Number chips ──────────────────────────────────────────────────────────────

class _NumberChips extends StatelessWidget {
  final List<int> numbers;
  final Color color;
  final ThemeData theme;

  const _NumberChips({
    required this.numbers,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: numbers.map((n) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            border: Border.all(color: color.withAlpha(70), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$n',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Summary text ──────────────────────────────────────────────────────────────

class _SummaryText extends StatelessWidget {
  final String en;
  final String zh;
  final ThemeData theme;

  const _SummaryText({required this.en, required this.zh, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(160),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            en,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            zh,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }
}
