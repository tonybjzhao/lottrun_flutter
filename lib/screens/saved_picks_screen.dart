import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import 'manual_pick_entry_screen.dart';
import '../models/lottery_draw.dart';
import '../services/local_storage_service.dart';
import '../services/lottery_history_csv_service.dart';
import '../services/lottery_service.dart';
import '../services/pick_result_service.dart';
import '../widgets/ball_row.dart';
import '../widgets/lotto_ball.dart';
import '../widgets/pick_share_card.dart';

// Country helpers ──────────────────────────────────────────────────────────────

String _countryFlag(String code) => switch (code) {
      'US' => '🇺🇸',
      'AU' => '🇦🇺',
      _ => '🌍',
    };

String _countryName(String code) => switch (code) {
      'US' => 'United States',
      'AU' => 'Australia',
      _ => 'Other',
    };

const _countryOrder = ['US', 'AU', 'OTHER'];

// ── Stats model ───────────────────────────────────────────────────────────────

class _PickStats {
  final int resolvedCount;
  final int bestMain;
  final int bestSupp;
  final String bestLotteryId;
  final int totalMainHits;
  final int totalSuppHits;
  final int luckScore;

  const _PickStats({
    required this.resolvedCount,
    required this.bestMain,
    required this.bestSupp,
    required this.bestLotteryId,
    required this.totalMainHits,
    required this.totalSuppHits,
    required this.luckScore,
  });

  int get totalHits => totalMainHits + totalSuppHits;
  bool get hasAnyResult => resolvedCount > 0;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class SavedPicksScreen extends StatefulWidget {
  const SavedPicksScreen({super.key});

  @override
  State<SavedPicksScreen> createState() => _SavedPicksScreenState();
}

class _SavedPicksScreenState extends State<SavedPicksScreen> {
  List<GeneratedPick> _picks = [];
  Map<String, List<LotteryDraw>> _drawsByLottery = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final picks = await LocalStorageService.instance.getSavedPicks();
    if (!mounted) return;

    final uniqueIds = picks.map((p) => p.lotteryId).toSet();
    final drawsMap = <String, List<LotteryDraw>>{};
    await Future.wait(uniqueIds.map((id) async {
      final lottery = LotteryService.instance.getLotteryById(id);
      if (lottery == null) return;
      try {
        final result = await LotteryHistoryCsvService.instance.fetchDraws(lottery);
        drawsMap[id] = result.draws;
      } catch (_) {
        drawsMap[id] = LotteryService.instance.getDraws(id);
      }
    }));

    if (mounted) {
      setState(() {
        _picks = picks;
        _drawsByLottery = drawsMap;
        _loading = false;
      });
    }
  }

  Future<void> _delete(GeneratedPick pick) async {
    await LocalStorageService.instance.deleteSavedPickById(pick.id);
    setState(() => _picks.removeWhere((p) => p.id == pick.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick deleted'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _addManual() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ManualPickEntryScreen()),
    );
    if (saved == true) _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all saved picks?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await LocalStorageService.instance.clearSavedPicks();
      setState(() => _picks.clear());
    }
  }

  Map<String, List<GeneratedPick>> _groupByCountry() {
    final map = <String, List<GeneratedPick>>{};
    for (final p in _picks) {
      map.putIfAbsent(p.countryCode, () => []).add(p);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Picks'),
        actions: [
          IconButton(
            onPressed: _addManual,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add My Numbers',
          ),
          if (_picks.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text('Clear all',
                  style: TextStyle(color: theme.colorScheme.error)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _picks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline_rounded,
                          size: 52,
                          color: theme.colorScheme.onSurface.withAlpha(55)),
                      const SizedBox(height: 12),
                      Text(
                        'No saved picks yet.\nTap Save after generating a pick.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(130),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildGroupedList(theme),
    );
  }

  List<LotteryDraw> _drawsFor(String lotteryId) =>
      _drawsByLottery[lotteryId] ?? LotteryService.instance.getDraws(lotteryId);

  List<GeneratedPick> _sortPicks(List<GeneratedPick> picks) {
    int group(GeneratedPick p) {
      final lottery = LotteryService.instance.getLotteryById(p.lotteryId);
      if (lottery == null) return 2;
      final result = checkPickResult(p, lottery, _drawsFor(p.lotteryId));
      if (result == null) return 2;        // legacy — no draw context
      if (result.isPending) return 0;      // pending draw
      return 1;                            // resolved
    }

    return [...picks]..sort((a, b) {
      final ga = group(a);
      final gb = group(b);
      if (ga != gb) return ga.compareTo(gb);
      if (ga == 0) {
        // pending: sort soonest draw first
        return a.drawDate!.compareTo(b.drawDate!);
      }
      // resolved + legacy: newest first
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  _PickStats _computeStats() {
    int resolvedCount = 0;
    int bestMain = 0;
    int bestSupp = 0;
    String bestLotteryId = '';
    int totalMainHits = 0;
    int totalSuppHits = 0;

    for (final pick in _picks) {
      final lottery = LotteryService.instance.getLotteryById(pick.lotteryId);
      if (lottery == null) continue;
      final result = checkPickResult(pick, lottery, _drawsFor(pick.lotteryId));
      if (result == null || result.isPending) continue;
      resolvedCount++;

      final mainHits = result.matchedMain;
      final suppHits = result.suppCategoryHits(lottery);
      totalMainHits += mainHits;
      totalSuppHits += suppHits;

      if (result.score > bestMain * 2 + bestSupp) {
        bestMain = mainHits;
        bestSupp = suppHits;
        bestLotteryId = pick.lotteryId;
      }
    }

    final luckScore =
        (50 + (totalMainHits + totalSuppHits) * 2 + bestMain * 3 + bestSupp * 2)
            .clamp(50, 99);

    return _PickStats(
      resolvedCount: resolvedCount,
      bestMain: bestMain,
      bestSupp: bestSupp,
      bestLotteryId: bestLotteryId,
      totalMainHits: totalMainHits,
      totalSuppHits: totalSuppHits,
      luckScore: luckScore,
    );
  }

  String? _bestPickId() {
    int bestScore = 0;
    String? bestId;
    for (final pick in _picks) {
      final lottery = LotteryService.instance.getLotteryById(pick.lotteryId);
      if (lottery == null) continue;
      final result = checkPickResult(pick, lottery, _drawsFor(pick.lotteryId));
      if (result == null || result.isPending) continue;
      if (result.score > bestScore) {
        bestScore = result.score;
        bestId = pick.id;
      }
    }
    return bestScore > 0 ? bestId : null;
  }

  Widget _buildGroupedList(ThemeData theme) {
    final grouped = _groupByCountry();
    final sections = _countryOrder.where(grouped.containsKey).toList();
    final bestId = _bestPickId();
    final stats = _computeStats();

    final items = <Widget>[];

    // ── Stats card (only when results available) ────────────────────────────
    if (stats.hasAnyResult) {
      items.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: _StatsCard(stats: stats),
      ));
    }

    items.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded,
              size: 13, color: theme.colorScheme.onSurface.withAlpha(100)),
          const SizedBox(width: 4),
          Text(
            'Pending draws first',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    ));

    for (final country in sections) {
      final picks = _sortPicks(grouped[country]!);
      items.add(_SectionHeader(
        flag: _countryFlag(country),
        name: _countryName(country),
        count: picks.length,
      ));
      for (final pick in picks) {
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _PickItem(
            pick: pick,
            draws: _drawsFor(pick.lotteryId),
            isBest: pick.id == bestId,
            onDelete: () => _delete(pick),
            onTap: () => Navigator.pop(context, pick),
          ),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: items,
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final _PickStats stats;

  const _StatsCard({required this.stats});

  String _bestText() {
    if (stats.bestMain == 0 && stats.bestSupp == 0) return 'None yet';
    if (stats.bestSupp == 0) return '${stats.bestMain} main';
    if (stats.bestMain == 0) return '${stats.bestSupp} supp';
    return '${stats.bestMain}+${stats.bestSupp}';
  }

  String _totalText() {
    if (stats.totalSuppHits == 0) return '${stats.totalMainHits} main';
    return '${stats.totalMainHits} main · ${stats.totalSuppHits} supp';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withAlpha(180),
            theme.colorScheme.secondaryContainer.withAlpha(120),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 5),
              Text(
                'Your Stats',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${stats.resolvedCount} result${stats.resolvedCount == 1 ? '' : 's'} checked',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(110),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatCell(
                icon: '🏆',
                value: _bestText(),
                label: 'Best',
                theme: theme,
              ),
              _StatDivider(),
              _StatCell(
                icon: '🎯',
                value: _totalText(),
                label: 'Total Hits',
                theme: theme,
              ),
              _StatDivider(),
              _StatCell(
                icon: '🍀',
                value: '${stats.luckScore}',
                label: 'Luck Score',
                theme: theme,
                highlight: stats.luckScore >= 80,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final ThemeData theme;
  final bool highlight;

  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight
                  ? Colors.green.shade700
                  : theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(120),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(30),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String flag;
  final String name;
  final int count;

  const _SectionHeader({
    required this.flag,
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text('$flag  $name',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single saved pick card ────────────────────────────────────────────────────

class _PickItem extends StatefulWidget {
  final GeneratedPick pick;
  final List<LotteryDraw> draws;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isBest;

  const _PickItem({
    required this.pick,
    required this.draws,
    required this.onDelete,
    required this.onTap,
    this.isBest = false,
  });

  @override
  State<_PickItem> createState() => _PickItemState();
}

class _PickItemState extends State<_PickItem> with SingleTickerProviderStateMixin {
  final _shareCardKey = GlobalKey();
  late final PickMatchResult? _result;
  AnimationController? _revealCtrl;

  @override
  void initState() {
    super.initState();
    final lottery = LotteryService.instance.getLotteryById(widget.pick.lotteryId);
    _result = lottery != null
        ? checkPickResult(widget.pick, lottery, widget.draws)
        : null;
    if (_result != null && !_result.isPending) {
      _revealCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _revealCtrl?.forward();
      });
    }
  }

  @override
  void dispose() {
    _revealCtrl?.dispose();
    super.dispose();
  }

  Lottery? get _lottery =>
      LotteryService.instance.getLotteryById(widget.pick.lotteryId);

  String get _lotteryName => _lottery?.name ?? widget.pick.lotteryId;

  String get _copyText {
    final main = widget.pick.mainNumbers.join('  ');
    final bonusLabel = switch (widget.pick.lotteryId) {
      'us_powerball' => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _ => 'Bonus',
    };
    final bonus =
        (widget.pick.bonusNumbers != null && widget.pick.bonusNumbers!.isNotEmpty)
            ? '\n+ $bonusLabel: ${widget.pick.bonusNumbers!.join(' ')}'
            : '';
    return '🎯 My AI $_lotteryName Pick\n${widget.pick.displayLabel}\n\n$main$bonus\n\nGenerated for fun — LottoRun AI';
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _copyText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copied to clipboard.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _shareCard(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await sharePickCard(repaintKey: _shareCardKey, btnContext: btnCtx);
  }

  // ── Result section ────────────────────────────────────────────────────────

  Widget _buildResultSection(ThemeData theme, PickMatchResult result) {
    if (result.isPending) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _pendingChip(theme),
      );
    }

    final ctrl = _revealCtrl;
    final lottery = _lottery;

    // Determine three-state result color for each pick number.
    // Main picks: red if hit draw.main, blue if hit draw.supp, grey otherwise.
    // Supp picks: red if hit draw.main, blue if hit draw.supp, grey otherwise.
    BallResultState mainState(int n) {
      if (result.matchedMainNumbers.contains(n)) return BallResultState.matchedMain;
      if (result.matchedMainInDrawSupp.contains(n)) return BallResultState.matchedSupp;
      return BallResultState.unmatched;
    }

    BallResultState bonusState(int n) {
      if (result.matchedBonusInDrawMain.contains(n)) return BallResultState.matchedMain;
      if (result.matchedBonusNumbers.contains(n)) return BallResultState.matchedSupp;
      return BallResultState.unmatched;
    }

    final mainNums = widget.pick.mainNumbers;
    final bonusNums = widget.pick.bonusNumbers ?? [];
    final isSupp = lottery?.bonusIsSupplementary ?? false;
    final bLabel = lottery?.bonusLabel;

    // For supp lotteries, bonus balls are draw-only — not displayed, not animated.
    final totalMatched = result.matchedMainNumbers.length +
        result.matchedMainInDrawSupp.length +
        (isSupp ? 0 : result.matchedBonusNumbers.length + result.matchedBonusInDrawMain.length);

    final dimAnim = ctrl != null
        ? CurvedAnimation(
            parent: ctrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
          )
        : null;

    int matchIdx = 0;
    Animation<double> nextMatchAnim() {
      final i = matchIdx++;
      final step = 0.55 / totalMatched.clamp(1, 99);
      final start = i * step * 0.75;
      final end = (start + step + 0.25).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: ctrl!,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );
    }

    Widget wrappedBall(int n, bool isBonusBall, BallResultState state, {double size = 36}) {
      final isHit = state != BallResultState.unmatched;
      final ball = LottoBall(number: n, isBonus: isBonusBall, resultState: state, size: size);
      if (ctrl == null) return ball;
      if (isHit) {
        final anim = nextMatchAnim();
        return AnimatedBuilder(
          animation: anim,
          builder: (_, child) => Transform.scale(
            scale: (0.5 + 0.5 * anim.value).clamp(0.0, 1.5),
            child: child,
          ),
          child: ball,
        );
      } else {
        return AnimatedBuilder(
          animation: dimAnim!,
          builder: (_, child) =>
              Opacity(opacity: (1.0 - 0.5 * dimAnim.value).clamp(0.5, 1.0), child: child),
          child: ball,
        );
      }
    }

    final textAnim = ctrl != null
        ? CurvedAnimation(
            parent: ctrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          )
        : null;

    String? drawLine;
    if (result.drawMainNumbers.isNotEmpty) {
      final datePart = result.drawDate != null
          ? ' (${DateFormat('d MMM').format(result.drawDate!.toLocal())})'
          : '';
      final mainStr = result.drawMainNumbers.join(' · ');
      final bonusStr = result.drawBonusNumbers?.isNotEmpty == true
          ? '  +  ${result.drawBonusNumbers!.join(' · ')}'
          : '';
      drawLine = 'Draw$datePart: $mainStr$bonusStr';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 18),

        // ── Level + match summary ───────────────────────────────────────────
        if (textAnim != null)
          AnimatedBuilder(
            animation: textAnim,
            builder: (_, child) => Opacity(opacity: textAnim.value, child: child!),
            child: _resultHeaderRow(theme, result),
          )
        else
          _resultHeaderRow(theme, result),

        // ── Progress dots ───────────────────────────────────────────────────
        if (lottery != null) ...[
          const SizedBox(height: 6),
          _buildProgressDots(theme, result, lottery),
        ],

        const SizedBox(height: 10),

        // ── ONE ROW: all pick numbers with result-state colors ──────────────
        // Red = matched draw main, Blue = matched draw supp, Grey = no match.
        // Supp picks shown slightly smaller after a separator.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < mainNums.length; i++) ...[
                wrappedBall(mainNums[i], false, mainState(mainNums[i])),
                if (i < mainNums.length - 1 || (bonusNums.isNotEmpty && !isSupp))
                  const SizedBox(width: 6),
              ],
              // Supp lotteries: bonus balls are draw-only, not user picks — skip.
              // Powerball-style: show label + bonus ball.
              if (bonusNums.isNotEmpty && !isSupp) ...[
                if (bLabel != null) ...[
                  Text(
                    bLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(120),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                for (var i = 0; i < bonusNums.length; i++) ...[
                  wrappedBall(bonusNums[i], true, bonusState(bonusNums[i])),
                  if (i < bonusNums.length - 1) const SizedBox(width: 6),
                ],
              ],
            ],
          ),
        ),

        // ── Draw result line ────────────────────────────────────────────────
        if (drawLine != null) ...[
          const SizedBox(height: 6),
          Text(
            drawLine,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(90),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        // ── Disclaimer ──────────────────────────────────────────────────────
        const SizedBox(height: 6),
        Text(
          'Check official results for prizes',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(70),
            fontStyle: FontStyle.italic,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _resultHeaderRow(ThemeData theme, PickMatchResult result) {
    final lottery = _lottery;
    if (lottery == null) return const SizedBox.shrink();

    final level = result.levelLabel(lottery);
    final levelEmoji = switch (level) {
      'Light hit' => '🙂 ',
      'Nice'      => '😊 ',
      'Solid'     => '🔥 ',
      'Strong'    => '💪 ',
      'Great'     => '💥 ',
      _           => '',
    };
    final summary = result.matchSummary(lottery);
    final total = result.matchedMain +
        (lottery.bonusIsSupplementary
            ? result.suppCategoryHits(lottery)
            : result.matchedBonus);
    final isGood = total >= 2;
    final isGreat = total >= 4;

    return Row(
      children: [
        // Level badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: isGreat
                ? Colors.green.shade100
                : isGood
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$levelEmoji$level',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isGreat
                  ? Colors.green.shade800
                  : isGood
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            summary,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isGood
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withAlpha(140),
              fontWeight: isGood ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        if (widget.isBest) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '🏆 Best',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressDots(ThemeData theme, PickMatchResult result, Lottery lottery) {
    final matchedMain = result.matchedMain;
    final total = lottery.mainCount;
    const redHit = Color(0xFFC62828);
    const blueSupp = Color(0xFF1565C0);

    return Row(
      children: [
        for (int i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Text(
              i < matchedMain ? '●' : '○',
              style: TextStyle(
                fontSize: 9,
                height: 1,
                color: i < matchedMain
                    ? redHit
                    : theme.colorScheme.onSurface.withAlpha(55),
              ),
            ),
          ),
        const SizedBox(width: 5),
        Text(
          '$matchedMain main',
          style: theme.textTheme.labelSmall?.copyWith(
            color: matchedMain > 0
                ? redHit
                : theme.colorScheme.onSurface.withAlpha(90),
            fontSize: 9,
            fontWeight: matchedMain > 0 ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        if (lottery.bonusIsSupplementary && result.suppCategoryHits(lottery) > 0) ...[
          const SizedBox(width: 5),
          Text(
            '+${result.suppCategoryHits(lottery)} supp',
            style: theme.textTheme.labelSmall?.copyWith(
              color: blueSupp,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ] else if (!lottery.bonusIsSupplementary && result.matchedBonus > 0) ...[
          const SizedBox(width: 5),
          Text(
            '+${lottery.bonusLabel ?? 'B'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: blueSupp,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _pendingChip(ThemeData theme) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⏳', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              widget.pick.drawLabel != null
                  ? 'Pending · ${widget.pick.drawLabel}'
                  : 'Pending',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('d MMM yyyy · HH:mm').format(widget.pick.createdAt.toLocal());
    final bonusNums = widget.pick.bonusNumbers ?? [];
    final lottery = _lottery;
    final result = _result;
    final hasResolvedResult = result != null && !result.isPending;

    return Stack(
      children: [
        if (lottery != null)
          Positioned(
            left: -10000,
            top: 0,
            width: 360,
            child: RepaintBoundary(
              key: _shareCardKey,
              child: PickShareCard(pick: widget.pick, lottery: lottery),
            ),
          ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _lotteryName,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (widget.pick.source == PickSource.manual)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '👤 My Pick',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onTertiaryContainer,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.pick.displayLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(160),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: theme.colorScheme.onSurface.withAlpha(120),
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Balls: normal row OR animated highlighted result ─
                  if (!hasResolvedResult)
                    BallRow(
                      mainNumbers: widget.pick.mainNumbers,
                      bonusNumbers: bonusNums,
                      bonusLabel: _lottery?.bonusLabel,
                      ballSize: 36,
                      spacing: 6,
                    ),

                  // ── Result section (pending chip / animated result) ──
                  if (result != null)
                    _buildResultSection(theme, result),

                  const SizedBox(height: 10),

                  // ── Actions ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _copy(context),
                          icon: const Icon(Icons.copy_rounded, size: 14),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Builder(
                          builder: (btnCtx) => OutlinedButton.icon(
                            onPressed: lottery != null
                                ? () => _shareCard(btnCtx)
                                : null,
                            icon: const Icon(Icons.share_rounded, size: 14),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              textStyle: const TextStyle(fontSize: 12),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onTap,
                          icon: const Icon(Icons.upload_rounded, size: 14),
                          label: const Text('Load'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            textStyle: const TextStyle(fontSize: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
