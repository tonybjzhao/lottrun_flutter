import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../services/draw_analysis_service.dart';

class HistoricalPatternMatchCard extends StatelessWidget {
  final Lottery lottery;
  final LotteryDraw targetDraw;
  final List<LotteryDraw> allDraws;

  const HistoricalPatternMatchCard({
    super.key,
    required this.lottery,
    required this.targetDraw,
    required this.allDraws,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final result = DrawAnalysisService.analyzeHistoricalPattern(
      lottery: lottery,
      targetDraw: targetDraw,
      allDraws: allDraws,
      similarDrawsLimit: 10,
    );

    if (result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Not enough history for pattern analysis (requires 52+ past draws).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Score header ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historical Pattern Match',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Post-result comparison · based on past 5 years',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scoreLabel(result.historicalMatchScore),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _scoreColor(result.historicalMatchScore),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreBadge(
                  score: result.historicalMatchScore, theme: theme),
            ],
          ),

          const SizedBox(height: 14),

          // ── Component scores ─────────────────────────────────────
          _ComponentScoreRow(
              label: 'Trend alignment',
              score: result.trendScore,
              theme: theme),
              _ComponentScoreRow(
              label: 'Popular/less-frequent alignment',
              score: result.hotColdAlignmentScore,
              theme: theme),
          _ComponentScoreRow(
              label: 'Odd/even structure',
              score: result.oddEvenStructureScore,
              theme: theme),
          _ComponentScoreRow(
              label: 'Low/high structure',
              score: result.lowHighStructureScore,
              theme: theme),
          _ComponentScoreRow(
              label: 'Sum range',
              score: result.sumRangeScore,
              theme: theme),
          _ComponentScoreRow(
              label: 'Consecutive pairs',
              score: result.consecutiveScore,
              theme: theme),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Draw structure chips ──────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(
                  label: result.oddEvenPattern,
                  icon: Icons.balance_rounded,
                  theme: theme),
              _InfoChip(
                  label: result.lowHighPattern,
                  icon: Icons.bar_chart_rounded,
                  theme: theme),
              _InfoChip(
                  label: result.sumRangeLabel,
                  icon: Icons.functions_rounded,
                  theme: theme),
              _InfoChip(
                label:
                    '${result.consecutiveNumberCount} consec pair${result.consecutiveNumberCount == 1 ? '' : 's'}',
                icon: Icons.link_rounded,
                theme: theme,
              ),
              _InfoChip(
                label:
                    '🔥 ${result.hotNumberCount} popular · ❄️ ${result.coldNumberCount} less frequent',
                icon: null,
                theme: theme,
              ),
            ],
          ),

          // ── Similar past results ─────────────────────────────────
          if (result.similarPastDraws.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Top 10 similar past results',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...result.similarPastDraws
                .map((s) => _SimilarDrawRow(similar: s, theme: theme)),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Summary ──────────────────────────────────────────────
          _SummaryBox(text: result.summary, theme: theme),
        ],
      ),
    );
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Strong alignment with historical patterns';
    if (score >= 60) return 'Moderate alignment with historical patterns';
    return 'Limited alignment with historical patterns';
  }

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.orange.shade600;
    return Colors.grey.shade500;
  }
}

// ── Score badge ───────────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  final int score;
  final ThemeData theme;

  const _ScoreBadge({required this.score, required this.theme});

  Color _color() {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 60) return Colors.orange.shade600;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(100), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          Text(
            '/100',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withAlpha(180),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Component score row ───────────────────────────────────────────────────────

class _ComponentScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final ThemeData theme;

  const _ComponentScoreRow({
    required this.label,
    required this.score,
    required this.theme,
  });

  // Color by score value, not by metric type
  Color _barColor() {
    if (score >= 80) return Colors.green.shade500;
    if (score >= 60) return Colors.orange.shade400;
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.onSurface.withAlpha(18),
                valueColor: AlwaysStoppedAnimation(_barColor()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface.withAlpha(160),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ThemeData theme;

  const _InfoChip(
      {required this.label, required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 12,
                color: theme.colorScheme.onSurface.withAlpha(140)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(180),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Similar draw row ──────────────────────────────────────────────────────────

class _SimilarDrawRow extends StatelessWidget {
  final SimilarDraw similar;
  final ThemeData theme;

  const _SimilarDrawRow({required this.similar, required this.theme});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('d MMM yyyy').format(similar.draw.drawDate.toLocal());
    final nums = similar.draw.mainNumbers.join('  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(140),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  nums,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${similar.sharedNumbers} numbers overlapped',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${similar.similarityScore.toStringAsFixed(0)}% structural similarity',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Summary box ───────────────────────────────────────────────────────────────

class _SummaryBox extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _SummaryBox({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(160),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withAlpha(180),
        ),
      ),
    );
  }
}
