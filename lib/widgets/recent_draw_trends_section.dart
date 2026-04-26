import 'package:flutter/material.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../services/draw_analysis_service.dart';
import '../services/premium_service.dart';
import 'premium_paywall_sheet.dart';

class RecentDrawTrendsSection extends StatefulWidget {
  final Lottery lottery;
  final List<LotteryDraw> draws;

  const RecentDrawTrendsSection({
    super.key,
    required this.lottery,
    required this.draws,
  });

  @override
  State<RecentDrawTrendsSection> createState() =>
      _RecentDrawTrendsSectionState();
}

class _RecentDrawTrendsSectionState extends State<RecentDrawTrendsSection> {
  int _drawCount = 20;
  static const _options = [10, 20, 50];

  RecentDrawTrends get _trends => DrawAnalysisService.analyzeRecentTrends(
        lottery: widget.lottery,
        draws: widget.draws,
        drawCount: _drawCount,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trends = _trends;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Draw Trends',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Based on last ${trends.drawCount} draws',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                    Text(
                      'Trends, not predictions',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(80),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              _DrawCountSelector(
                value: _drawCount,
                options: _options,
                onChanged: (v) => setState(() => _drawCount = v),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (trends.drawCount == 0)
            _emptyState(theme)
          else ...[
            // ── Hot numbers ──────────────────────────────────────
            _MetricRow(
              label: 'Hot numbers',
              tooltip: 'Appeared more often in recent draws',
              child: _NumberChips(
                numbers: trends.topFrequent,
                indicator: '🔥',
                color: Colors.orange.shade700,
                theme: theme,
              ),
            ),
            const SizedBox(height: 8),

            // ── Cold numbers ─────────────────────────────────────
            _MetricRow(
              label: 'Cold numbers',
              tooltip: 'Appeared less often in recent draws',
              child: _NumberChips(
                numbers: trends.bottomFrequent,
                indicator: '❄️',
                color: Colors.blue.shade600,
                theme: theme,
              ),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Stats row ────────────────────────────────────────
            Row(
              children: [
                _StatChip(
                  label: 'Avg sum',
                  value: trends.averageSum.toStringAsFixed(0),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Odd/Even',
                  value: trends.mostCommonOddEven,
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Low/High',
                  value: trends.mostCommonLowHigh,
                  theme: theme,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _StatChip(
                  label: 'Avg consec pairs',
                  value: trends.avgConsecutivePairs.toStringAsFixed(1),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _TrendStrengthChip(
                    strength: trends.trendStrength, theme: theme),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Summary ──────────────────────────────────────────
            _SummaryBox(text: trends.summary, theme: theme),

            const SizedBox(height: 10),

            // ── Premium teaser ───────────────────────────────────
            _PremiumTeaser(theme: theme),
          ],
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Not enough draw history for analysis.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
        ),
      );
}

// ── Premium teaser ────────────────────────────────────────────────────────────

class _PremiumTeaser extends StatelessWidget {
  final ThemeData theme;
  const _PremiumTeaser({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PremiumService.instance,
      builder: (context, _) {
        if (PremiumService.instance.isPremium) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => showPremiumPaywall(context),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withAlpha(12),
              border: Border.all(
                  color: const Color(0xFF7C3AED).withAlpha(50), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unlock deeper trends — Advanced Analysis',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF7C3AED),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 16,
                    color: const Color(0xFF7C3AED).withAlpha(180)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Draw count selector ───────────────────────────────────────────────────────

class _DrawCountSelector extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  const _DrawCountSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((opt) {
        final selected = opt == value;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(left: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$opt',
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withAlpha(160),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Number chips ──────────────────────────────────────────────────────────────

class _NumberChips extends StatelessWidget {
  final List<int> numbers;
  final String indicator;
  final Color color;
  final ThemeData theme;

  const _NumberChips({
    required this.numbers,
    required this.indicator,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (numbers.isEmpty) {
      return Text('—',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(100)));
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: numbers.map((n) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            border: Border.all(color: color.withAlpha(80), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(indicator, style: const TextStyle(fontSize: 10)),
              const SizedBox(width: 3),
              Text(
                '$n',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Metric row ────────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  final String label;
  final String tooltip;
  final Widget child;

  const _MetricRow({
    required this.label,
    required this.tooltip,
    required this.child,
  });

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
            child: Tooltip(
              message: tooltip,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.info_outline_rounded,
                      size: 10,
                      color:
                          theme.colorScheme.onSurface.withAlpha(80)),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _StatChip({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trend strength chip ───────────────────────────────────────────────────────

class _TrendStrengthChip extends StatelessWidget {
  final TrendStrength strength;
  final ThemeData theme;

  const _TrendStrengthChip(
      {required this.strength, required this.theme});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (strength) {
      TrendStrength.strong =>
        ('Strong trend', '📈', Colors.orange.shade700),
      TrendStrength.balanced =>
        ('Balanced', '⚖️', Colors.teal.shade600),
      TrendStrength.random =>
        ('Random-like', '🎲', Colors.grey.shade600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(60), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
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
