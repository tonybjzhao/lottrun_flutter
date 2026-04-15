import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../models/lottery_history_result.dart';
import '../data/seed_lotteries.dart';
import '../services/lottery_history_csv_service.dart';
import '../widgets/lotto_ball.dart';

class HistoryScreen extends StatefulWidget {
  final Lottery lottery;

  const HistoryScreen({super.key, required this.lottery});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Lottery _lottery;
  late Future<LotteryHistoryResult> _historyFuture;

  @override
  void initState() {
    super.initState();
    _lottery = widget.lottery;
    _historyFuture = _loadDraws(_lottery);
  }

  void _onLotteryChanged(Lottery? l) {
    if (l == null) return;
    setState(() {
      _lottery = l;
      _historyFuture = _loadDraws(l);
    });
  }

  Future<LotteryHistoryResult> _loadDraws(Lottery lottery) {
    return LotteryHistoryCsvService.instance.fetchDraws(lottery);
  }

  Future<void> _refresh() async {
    final future = _loadDraws(_lottery);
    setState(() => _historyFuture = future);
    await future;
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
            child: FutureBuilder<LotteryHistoryResult>(
              future: _historyFuture,
              builder: (context, snapshot) => Row(
                children: [
                  Text(
                    snapshot.hasData
                        ? '${snapshot.data!.draws.length} draws'
                        : 'Loading...',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Draw list ───────────────────────────────────────────
          Expanded(
            child: FutureBuilder<LotteryHistoryResult>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _errorState(theme, snapshot.error.toString());
                }

                final history = snapshot.data;
                final draws = history?.draws ?? const <LotteryDraw>[];
                if (draws.isEmpty) {
                  return _emptyState(theme);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: draws.length + 1,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _historyStatusBanner(theme, history);
                      }

                      final draw = draws[index - 1];
                      return _DrawTile(draw: draw, lottery: _lottery);
                    },
                  ),
                );
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

  Widget _historyStatusBanner(ThemeData theme, LotteryHistoryResult? history) {
    if (history == null) {
      return const SizedBox.shrink();
    }

    if (history.source != LotteryHistorySource.cache) {
      return const SizedBox(height: 12);
    }

    final updatedAtText = history.loadedAt == null
        ? null
        : DateFormat('d MMM, h:mm a').format(history.loadedAt!.toLocal());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          updatedAtText == null
              ? 'Offline mode: showing saved results'
              : 'Offline mode: showing saved results from $updatedAtText',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
            fontWeight: FontWeight.w600,
          ),
        ),
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
            'No history data available yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(ThemeData theme, String message) {
    final friendlyMessage = message.contains(
      'No internet connection and no saved lottery history yet.',
    )
        ? 'No internet connection and no saved lottery history yet.'
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: theme.colorScheme.error.withAlpha(180)),
            const SizedBox(height: 12),
            Text(
              'Failed to load history.',
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              friendlyMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(140),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() => _historyFuture = _loadDraws(_lottery));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
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
