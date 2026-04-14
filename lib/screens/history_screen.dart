import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../data/seed_lotteries.dart';
import '../services/lottery_service.dart';
import '../widgets/lotto_ball.dart';

class HistoryScreen extends StatefulWidget {
  final Lottery lottery;

  const HistoryScreen({super.key, required this.lottery});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Lottery _lottery;
  late List<LotteryDraw> _draws;

  @override
  void initState() {
    super.initState();
    _lottery = widget.lottery;
    _draws = LotteryService.instance.getDraws(_lottery.id);
  }

  void _onLotteryChanged(Lottery? l) {
    if (l == null) return;
    setState(() {
      _lottery = l;
      _draws = LotteryService.instance.getDraws(l.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          // ── Lottery picker ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Lottery',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Lottery>(
                  value: _lottery,
                  isExpanded: true,
                  items: kSeedLotteries.map((l) {
                    return DropdownMenuItem(
                      value: l,
                      child: Text(l.displayName),
                    );
                  }).toList(),
                  onChanged: _onLotteryChanged,
                ),
              ),
            ),
          ),

          // ── Draw count badge ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${_draws.length} draws',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Draw list ───────────────────────────────────────────
          Expanded(
            child: _draws.isEmpty
                ? _emptyState(theme)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _draws.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final draw = _draws[index];
                      return _DrawTile(draw: draw, lottery: _lottery);
                    },
                  ),
          ),

          // ── Ad banner placeholder ───────────────────────────────
          Container(
            height: 52,
            color: theme.colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: Text(
              'Ad Banner Placeholder',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              size: 48, color: theme.colorScheme.onSurface.withAlpha(60)),
          const SizedBox(height: 12),
          Text(
            'No history data yet.\n(Oz Lotto & Saturday Lotto coming soon)',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawTile extends StatelessWidget {
  final LotteryDraw draw;
  final Lottery lottery;

  const _DrawTile({required this.draw, required this.lottery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('d MMM yyyy').format(draw.drawDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...draw.mainNumbers
                  .map((n) => LottoBall(number: n, size: 36)),
              if (draw.bonusNumbers != null)
                ...draw.bonusNumbers!
                    .map((n) => LottoBall(number: n, isBonus: true, size: 36)),
            ],
          ),
        ],
      ),
    );
  }
}
