import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/pick_share_card.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../data/seed_lotteries.dart';
import '../services/generator_service.dart';
import '../services/lottery_service.dart';
import '../services/analytics_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/disclaimer_card.dart';
import '../widgets/lotto_ball.dart';
import '../widgets/result_panel.dart';
import '../widgets/style_chip_group.dart';
import 'history_screen.dart';
import 'saved_picks_screen.dart';

// ── Home screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Lottery _selectedLottery = kSeedLotteries.first;
  PlayStyle _selectedStyle = PlayStyle.balanced;
  GeneratedPick? _pick;
  bool _isSaved = false;
  bool _isLoading = false;
  bool _isPickExpanded = false;
  int _luckOffset = 0; // shifts ±10 each generate
  int _streak = 0;
  int _insightKey = 0; // cycles insight message on each generate
  bool _showReadyFlash = false;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _restorePrefs();
    _initStreak();
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  Future<void> _initStreak() async {
    final streak = await LocalStorageService.instance.recordDailyOpen();
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _restorePrefs() async {
    final storage = LocalStorageService.instance;
    final lotteryId = await storage.getLastLotteryId();
    final style = await storage.getLastStyle();
    final pick = await storage.getLastPick();

    if (!mounted) return;
    setState(() {
      if (lotteryId != null) {
        _selectedLottery = kSeedLotteries.firstWhere(
          (l) => l.id == lotteryId,
          orElse: () => kSeedLotteries.first,
        );
      }
      if (style != null) _selectedStyle = style;
      if (pick != null) {
        _pick = pick;
        _isSaved = true;
      }
    });
  }

  void _showThreePicks() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ThreePicksSheet(
        lottery: _selectedLottery,
        style: _selectedStyle,
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    final history =
        LotteryService.instance.getRecentDraws(_selectedLottery.id, limit: 100);

    final pick = GeneratorService.instance.generate(
      lottery: _selectedLottery,
      style: _selectedStyle,
      history: history,
    );

    await LocalStorageService.instance.saveLastLotteryId(_selectedLottery.id);
    await LocalStorageService.instance.saveLastStyle(_selectedStyle);
    unawaited(AnalyticsService.logGenerateNumbers(
      lottery: _selectedLottery.id,
      strategy: _selectedStyle.analyticsName,
      pickCount: 1,
      source: 'home',
    ));

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _pick = pick;
      _isSaved = false;
      _isLoading = false;
      _isPickExpanded = false;
      _luckOffset = Random().nextInt(21) - 10; // −10 to +10
      _insightKey++;
      _showReadyFlash = true;
    });

    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showReadyFlash = false);
    });
  }

  static const _insightMessages = {
    PlayStyle.balanced: [
      'AI sees a balanced spread for today',
      'History points to an even distribution',
      'Balanced picks look stronger today',
    ],
    PlayStyle.hot: [
      'Hot trend is active tonight 🔥',
      'Recent draws favour these numbers',
      'AI detects a hot-number streak',
    ],
    PlayStyle.cold: [
      'AI sees a cold-number comeback today ❄️',
      'Overdue numbers are in your corner',
      'Cold picks may be ready to break out',
    ],
    PlayStyle.random: [
      'Sometimes pure luck is all you need 🎲',
      'Chaos is a strategy too',
      'Pure randomness — trust the universe',
    ],
  };

  String get _insightText {
    final msgs = _insightMessages[_selectedStyle]!;
    return msgs[_insightKey % msgs.length];
  }

  Future<void> _savePick() async {
    if (_pick == null) return;
    HapticFeedback.lightImpact();
    await Future.wait([
      LocalStorageService.instance.saveLastPick(_pick!),
      LocalStorageService.instance.savePickToHistory(_pick!),
    ]);
    unawaited(AnalyticsService.logNumbersSaved(
      lottery: _selectedLottery.id,
      strategy: _selectedStyle.analyticsName,
    ));
    if (!mounted) return;
    setState(() => _isSaved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Saved to Saved Picks'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SavedPicksScreen()),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'LottoRun ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'AI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.secondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Smart picks from real draw history',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onPrimary.withAlpha(180),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedPicksScreen()),
            ),
            icon: const Icon(Icons.bookmark_rounded),
            tooltip: 'Saved Picks',
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => HistoryScreen(lottery: _selectedLottery)),
            ),
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _InsightPillRow(),
            const SizedBox(height: 12),
            const DisclaimerCard(),
            const SizedBox(height: 16),

            // ── Lottery selector ──────────────────────────────────
            Text('Lottery', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            InputDecorator(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Lottery>(
                  value: _selectedLottery,
                  isExpanded: true,
                  items: kSeedLotteries.map((l) {
                    return DropdownMenuItem(
                      value: l,
                      child: Text(l.displayName),
                    );
                  }).toList(),
                  onChanged: (l) {
                    if (l == null) return;
                    unawaited(AnalyticsService.logLotteryChanged(
                      fromLottery: _selectedLottery.id,
                      toLottery: l.id,
                    ));
                    setState(() {
                      _selectedLottery = l;
                      _pick = null;
                      _isSaved = false;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Style selector ────────────────────────────────────
            Text('Play Style', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            StyleChipGroup(
              selected: _selectedStyle,
              onChanged: (s) {
                unawaited(AnalyticsService.logPickStrategySelected(
                  strategy: s.analyticsName,
                  lottery: _selectedLottery.id,
                ));
                setState(() => _selectedStyle = s);
              },
            ),
            const SizedBox(height: 24),

            // ── Luck label + countdown ────────────────────────────
            _LuckBar(
              lottery: _selectedLottery,
              luckOffset: _luckOffset,
              streak: _streak,
            ),
            const SizedBox(height: 12),

            // ── Generate buttons ──────────────────────────────────
            _GradientButton(
              onPressed: _isLoading ? null : _generate,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _showThreePicks,
              icon: const Icon(Icons.filter_3_rounded, size: 18),
              label: const Text('Generate 3 Smart Picks'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // ── AI insight line ───────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
              ),
              child: _pick != null
                  ? Padding(
                      key: ValueKey(_showReadyFlash
                          ? 'ready-$_insightKey'
                          : 'insight-$_insightKey'),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(
                            _showReadyFlash
                                ? Icons.check_circle_rounded
                                : Icons.auto_awesome_rounded,
                            size: 14,
                            color: _showReadyFlash
                                ? Colors.green.shade400
                                : theme.colorScheme.primary.withAlpha(180),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _showReadyFlash
                                  ? '✨ Your AI pick is ready'
                                  : _insightText,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _showReadyFlash
                                    ? Colors.green.shade400
                                    : theme.colorScheme.primary.withAlpha(200),
                                fontStyle: FontStyle.italic,
                                fontWeight: _showReadyFlash
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-insight')),
            ),

            // ── Result / empty state ──────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              ),
              child: _pick == null
                  ? Padding(
                      key: const ValueKey('empty'),
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.casino_outlined,
                              size: 52,
                              color: theme.colorScheme.onSurface.withAlpha(55)),
                          const SizedBox(height: 12),
                          Text(
                            'Try a fun pick based on real draw history 🎲',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isPickExpanded
                      ? ResultPanel(
                          key: const ValueKey('expanded'),
                          pick: _pick!,
                          lottery: _selectedLottery,
                          recentDraw: LotteryService.instance
                              .getRecentDraws(_selectedLottery.id, limit: 1)
                              .firstOrNull,
                          onSave: _savePick,
                          isSaved: _isSaved,
                          onCollapse: () =>
                              setState(() => _isPickExpanded = false),
                        )
                      : _CompactPickBanner(
                          key: ValueKey(_pick!.createdAt),
                          pick: _pick!,
                          lottery: _selectedLottery,
                          onExpand: () =>
                              setState(() => _isPickExpanded = true),
                        ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

    );
  }
}

// ── Insight pill row ──────────────────────────────────────────────────────────

class _InsightPillRow extends StatelessWidget {
  const _InsightPillRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pillStyle = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final pills = [
      ('🔥', 'Hot trend'),
      ('❄️', 'Cold comeback'),
      ('🤖', 'AI mixed pick'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (icon, label) in pills)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$icon  $label',
                style: pillStyle?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Luck bar (daily luck % + draw countdown) ─────────────────────────────────

class _LuckBar extends StatelessWidget {
  final Lottery lottery;
  final int luckOffset;
  final int streak;

  const _LuckBar({
    required this.lottery,
    this.luckOffset = 0,
    this.streak = 0,
  });

  /// Base daily value seeded by calendar date (65–92), shifted by luckOffset.
  int get _luckPct {
    final d = DateTime.now().toLocal();
    final seed = d.year * 10000 + d.month * 100 + d.day;
    final base = 65 + Random(seed).nextInt(28); // 65–92
    return (base + luckOffset).clamp(50, 99);
  }

  /// Next draw countdown for AU (AEST UTC+10) and US (ET UTC-5) lotteries.
  String _nextDraw() {
    // AU: single weekday draw at 20:30 AEST
    final auWeekday = switch (lottery.id) {
      'au_powerball' => DateTime.thursday,
      'au_ozlotto'   => DateTime.tuesday,
      'au_saturday'  => DateTime.saturday,
      _              => null,
    };
    if (auWeekday != null) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 10));
      var next = now;
      while (next.weekday != auWeekday) {
        next = next.add(const Duration(days: 1));
      }
      if (next.day == now.day &&
          (now.hour > 20 || (now.hour == 20 && now.minute >= 30))) {
        next = next.add(const Duration(days: 7));
      }
      final diff = next.difference(now);
      if (diff.inDays >= 2) return 'Next draw in ${diff.inDays}d';
      if (diff.inHours >= 1) return 'Next draw in ${diff.inHours}h';
      return 'Draw soon!';
    }

    // US: multiple draw days per week at 22:59 ET (UTC-5)
    final usDrawDays = switch (lottery.id) {
      'us_powerball'    => [DateTime.monday, DateTime.wednesday, DateTime.saturday],
      'us_megamillions' => [DateTime.tuesday, DateTime.friday],
      _                 => null,
    };
    if (usDrawDays != null) {
      final now = DateTime.now().toUtc().subtract(const Duration(hours: 5));
      DateTime? nearest;
      for (final weekday in usDrawDays) {
        var candidate = now;
        while (candidate.weekday != weekday) {
          candidate = candidate.add(const Duration(days: 1));
        }
        // Draw closes at 22:59 ET; if past that on draw day, skip to next occurrence
        if (candidate.day == now.day &&
            (now.hour > 22 || (now.hour == 22 && now.minute >= 59))) {
          candidate = candidate.add(const Duration(days: 7));
        }
        if (nearest == null || candidate.isBefore(nearest)) {
          nearest = candidate;
        }
      }
      if (nearest != null) {
        final diff = nearest.difference(now);
        if (diff.inDays >= 2) return 'Next draw in ${diff.inDays}d';
        if (diff.inHours >= 1) return 'Next draw in ${diff.inHours}h';
        return 'Draw soon!';
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countdown = _nextDraw();
    final right = streak >= 2
        ? '🔥 $streak-day streak'
        : countdown.isNotEmpty
            ? '⏳ $countdown'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '🍀 Today\'s luck: $_luckPct%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (right != null) ...[
              const Spacer(),
              Text(
                right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(130),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Gradient Try My Luck button ───────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const _GradientButton({required this.onPressed, required this.isLoading});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.onPressed == null
                ? null
                : const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: widget.onPressed == null ? Colors.grey.shade300 : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Generate AI Pick',
                          style: TextStyle(
                            color: widget.onPressed == null
                                ? Colors.grey.shade600
                                : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 3-picks bottom sheet ──────────────────────────────────────────────────────

class _ThreePicksSheet extends StatefulWidget {
  final Lottery lottery;
  final PlayStyle style;

  const _ThreePicksSheet({required this.lottery, required this.style});

  @override
  State<_ThreePicksSheet> createState() => _ThreePicksSheetState();
}

class _ThreePicksSheetState extends State<_ThreePicksSheet>
    with TickerProviderStateMixin {
  late List<GeneratedPick> _picks;
  late AnimationController _animController;
  bool _isRegenerating = false;
  List<bool> _savedStates = [false, false, false];
  final List<GlobalKey> _shareKeys = List.generate(3, (_) => GlobalKey());

  /// Use different history windows per pick so each pick has a different
  /// frequency distribution → naturally diverse results.
  static const _historyWindows = [30, 60, 100];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _picks = _generatePicks();
    _animController.forward();
    unawaited(AnalyticsService.logGenerateNumbers(
      lottery: widget.lottery.id,
      strategy: widget.style.analyticsName,
      pickCount: 3,
      source: 'three_picks',
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<GeneratedPick> _generatePicks() {
    final raw = List.generate(3, (i) {
      final history = LotteryService.instance
          .getRecentDraws(widget.lottery.id, limit: _historyWindows[i]);
      return GeneratorService.instance.generate(
        lottery: widget.lottery,
        style: widget.style,
        history: history,
      );
    });
    return _diversifyPowerballs(raw);
  }

  /// Ensure each pick has a distinct Powerball number so users don't think
  /// duplicate powerballs mean something is broken.
  List<GeneratedPick> _diversifyPowerballs(List<GeneratedPick> picks) {
    if (!widget.lottery.hasBonus) return picks;
    final min = widget.lottery.bonusMin!;
    final max = widget.lottery.bonusMax!;
    final used = <int>{};
    final pool = ([for (var i = min; i <= max; i++) i]..shuffle());

    return picks.map((pick) {
      if (pick.bonusNumbers == null || pick.bonusNumbers!.isEmpty) return pick;
      var bonus = pick.bonusNumbers!.first;
      if (used.contains(bonus)) {
        final replacement = pool.firstWhere((n) => !used.contains(n),
            orElse: () => bonus);
        bonus = replacement;
      }
      used.add(bonus);
      return GeneratedPick(
        lotteryId: pick.lotteryId,
        style: pick.style,
        mainNumbers: pick.mainNumbers,
        bonusNumbers: [bonus],
        createdAt: pick.createdAt,
      );
    }).toList();
  }

  Future<void> _regenerate() async {
    HapticFeedback.lightImpact();
    setState(() => _isRegenerating = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _picks = _generatePicks();
      _isRegenerating = false;
      _savedStates = [false, false, false];
    });
    unawaited(AnalyticsService.logGenerateNumbers(
      lottery: widget.lottery.id,
      strategy: widget.style.analyticsName,
      pickCount: 3,
      source: 'three_picks',
    ));
    _animController
      ..reset()
      ..forward();
  }


  Future<void> _saveAll() async {
    HapticFeedback.lightImpact();
    await Future.wait(_picks.map(LocalStorageService.instance.savePickToHistory));
    if (!mounted) return;
    setState(() => _savedStates = [true, true, true]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All 3 picks saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAll(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await sharePickCards(repaintKeys: _shareKeys, btnContext: btnCtx);
  }

  Animation<double> _cardAnimation(int index) {
    final start = index * 0.18;
    return CurvedAnimation(
      parent: _animController,
      curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.4,
      maxChildSize: 0.93,
      builder: (_, controller) => Column(
        children: [
          // ── Handle ─────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header row ─────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3 Picks · ${widget.style.label} · ${widget.lottery.name}',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Generated from 5 years of real draw history',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _isRegenerating ? null : _regenerate,
                  icon: _isRegenerating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label:
                      Text(_isRegenerating ? 'Generating…' : 'Regenerate'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Pick list ───────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: _picks.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final anim = _cardAnimation(i);
                return AnimatedBuilder(
                  animation: anim,
                  builder: (_, child) => Opacity(
                    opacity: anim.value.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - anim.value)),
                      child: child,
                    ),
                  ),
                  child: _MiniPickCard(
                    pick: _picks[i],
                    label: const ['⭐ Best AI Pick', '🔥 Hot Trend Pick', '🎲 Lucky Mix Pick'][i],
                    microcopy: const [
                      'Based on balanced frequency',
                      'Leans toward recent hot numbers',
                      'Mix of hot, cold, and random',
                    ][i],
                    lottery: widget.lottery,
                    shareCardKey: _shareKeys[i],
                    isSaved: _savedStates[i],
                    onSave: () async {
                      HapticFeedback.lightImpact();
                      final messenger = ScaffoldMessenger.of(context);
                      await LocalStorageService.instance.savePickToHistory(_picks[i]);
                      if (!mounted) return;
                      setState(() => _savedStates[i] = true);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Pick saved'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // ── Footer actions ──────────────────────────────────────
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _savedStates.every((s) => s) ? null : _saveAll,
                      icon: const Icon(Icons.bookmark_rounded, size: 18),
                      label: const Text('Save All'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Builder(
                      builder: (btnCtx) => FilledButton.icon(
                        onPressed: () => _shareAll(btnCtx),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Share All'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact pick banner (home screen lightweight preview) ─────────────────────

class _CompactPickBanner extends StatefulWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final VoidCallback onExpand;

  const _CompactPickBanner({
    super.key,
    required this.pick,
    required this.lottery,
    required this.onExpand,
  });

  @override
  State<_CompactPickBanner> createState() => _CompactPickBannerState();
}

class _CompactPickBannerState extends State<_CompactPickBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final total = widget.pick.mainNumbers.length +
        (widget.pick.bonusNumbers?.length ?? 0);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 280 + total * 80),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _ballAnim(int index, int total) {
    final step = 0.6 / total;
    final start = index * step;
    final end = (start + 0.5).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );
  }

  Future<void> _shareCard(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await sharePickCard(repaintKey: _shareCardKey, btnContext: btnCtx);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainNums = widget.pick.mainNumbers;
    final bonusNums = widget.pick.bonusNumbers ?? [];
    final total = mainNums.length + bonusNums.length;

    return Stack(
      children: [
        // ── Off-screen share card (must be painted for toImage()) ─
        Positioned(
          left: -10000,
          top: 0,
          width: 360,
          child: RepaintBoundary(
            key: _shareCardKey,
            child: PickShareCard(pick: widget.pick, lottery: widget.lottery),
          ),
        ),

        // ── Visible banner ─────────────────────────────────────
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (_, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: child,
            ),
          ),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: theme.colorScheme.primary.withAlpha(40),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: widget.onExpand,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 10, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label row ───────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'AI Pick · ${widget.pick.style.tagline}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Builder(
                          builder: (btnCtx) => TextButton.icon(
                            onPressed: () => _shareCard(btnCtx),
                            icon: const Icon(Icons.share_rounded, size: 14),
                            label: const Text('Share'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurface.withAlpha(100),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ── Staggered balls ─────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < mainNums.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: AnimatedBuilder(
                                animation: _ballAnim(i, total),
                                builder: (_, child) => Transform.scale(
                                  scale: _ballAnim(i, total)
                                      .value
                                      .clamp(0.0, 1.0),
                                  child: child,
                                ),
                                child: LottoBall(
                                    number: mainNums[i], size: 38),
                              ),
                            ),
                          if (bonusNums.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            for (var i = 0; i < bonusNums.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: AnimatedBuilder(
                                  animation:
                                      _ballAnim(mainNums.length + i, total),
                                  builder: (_, child) => Transform.scale(
                                    scale: _ballAnim(
                                            mainNums.length + i, total)
                                        .value
                                        .clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                  child: LottoBall(
                                      number: bonusNums[i],
                                      isBonus: true,
                                      size: 38),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mini pick card ────────────────────────────────────────────────────────────

class _MiniPickCard extends StatefulWidget {
  final GeneratedPick pick;
  final String label;
  final String microcopy;
  final Lottery lottery;
  final bool isSaved;
  final VoidCallback onSave;
  final GlobalKey shareCardKey;

  const _MiniPickCard({
    required this.pick,
    required this.label,
    required this.microcopy,
    required this.lottery,
    required this.isSaved,
    required this.onSave,
    required this.shareCardKey,
  });

  @override
  State<_MiniPickCard> createState() => _MiniPickCardState();
}

class _MiniPickCardState extends State<_MiniPickCard> {
  GlobalKey get _shareCardKey => widget.shareCardKey;

  String _buildCopyText() {
    final main = widget.pick.mainNumbers.join('  ');
    final bonus = (widget.pick.bonusNumbers != null && widget.pick.bonusNumbers!.isNotEmpty)
        ? ' + ${widget.pick.bonusNumbers!.join(' ')}'
        : '';
    return '${widget.label}\n${widget.lottery.name}: $main$bonus\nGenerated for fun — LottoRun AI 🎯';
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildCopyText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.label} copied to clipboard.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareCard(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await sharePickCard(repaintKey: _shareCardKey, btnContext: btnCtx);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned(
          left: -10000,
          top: 0,
          width: 360,
          child: RepaintBoundary(
            key: _shareCardKey,
            child: PickShareCard(pick: widget.pick, lottery: widget.lottery),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.microcopy,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(110),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _copy(context),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    Builder(
                      builder: (btnCtx) => IconButton(
                        onPressed: () => _shareCard(btnCtx),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        tooltip: 'Share',
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.isSaved ? null : widget.onSave,
                      icon: Icon(
                        widget.isSaved ? Icons.bookmark : Icons.bookmark_outline_rounded,
                        size: 18,
                      ),
                      tooltip: widget.isSaved ? 'Saved' : 'Save',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...widget.pick.mainNumbers
                        .map((n) => LottoBall(number: n, size: 38)),
                    if (widget.pick.bonusNumbers != null)
                      ...widget.pick.bonusNumbers!.map(
                          (n) => LottoBall(number: n, isBonus: true, size: 38)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
