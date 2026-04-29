import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/ball_row.dart';
import '../widgets/pick_share_card.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../data/seed_lotteries.dart';
import '../services/generator_service.dart';
import '../services/lottery_service.dart';
import '../services/analytics_service.dart';
import '../services/draw_date_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/result_notification_service.dart';
import '../widgets/disclaimer_card.dart';
import '../widgets/lotto_ball.dart';
import '../widgets/result_panel.dart';
import '../widgets/style_chip_group.dart';
import 'history_screen.dart';
import 'saved_picks_screen.dart';
import 'settings_screen.dart';

// ── Home screen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Lottery _selectedLottery = kSeedLotteries.first;
  PlayStyle _selectedStyle = PlayStyle.balanced;

  // Single pick state
  GeneratedPick? _pick;
  bool _isSaved = false;
  bool _isLoading = false;
  bool _isPickExpanded = false;
  int _luckOffset = 0;
  int _streak = 0;
  int _insightKey = 0;
  bool _showReadyFlash = false;
  Timer? _flashTimer;

  // Three picks inline state
  List<GeneratedPick>? _threePicks;
  List<bool> _threePicksSaved = [false, false, false];
  bool _isThreePicksLoading = false;

  static const _kThreePicksStyles = [
    PlayStyle.balanced,
    PlayStyle.hot,
    PlayStyle.random,
  ];
  static const _kThreePicksWindows = [100, 60, 30];
  static final _kThreePicksLabels = [
    '⭐ Generated Pick',
    'Common Pattern',
    '🎲 Random Surprise',
  ];
  static final _kThreePicksBadges = [
    'Balanced',
    'Popular',
    'Random',
  ];
  static final _kThreePicksMicrocopy = [
    'Balanced selection for today 👀',
    'These numbers appeared often recently',
    'Random selection each time 🎲',
  ];
  static const _kThreePicksColors = [
    Color(0xFFF59E0B), // amber  — Best Pick
    Color(0xFFEA580C), // orange — Hot
    Color(0xFF7C3AED), // purple — Lucky
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restorePrefs();
    _initStreak();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final launchedFromNotif =
          await NotificationService.instance.checkLaunchedFromNotification();
      if (launchedFromNotif && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedPicksScreen()),
        );
      } else {
        unawaited(ResultNotificationService.instance.checkAndNotify());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ResultNotificationService.instance.checkAndNotify());
      unawaited(_syncSavedFlags());
    }
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
    final savedPicks = await storage.getSavedPicks();

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
        _isSaved = savedPicks.any((saved) => saved.id == pick.id);
      }
    });
  }

  Future<void> _syncSavedFlags() async {
    final savedPicks = await LocalStorageService.instance.getSavedPicks();
    if (!mounted) return;
    setState(() {
      if (_pick != null) {
        _isSaved = savedPicks.any((saved) => saved.id == _pick!.id);
      } else {
        _isSaved = false;
      }

      if (_threePicks != null) {
        _threePicksSaved = _threePicks!
            .map((pick) => savedPicks.any((saved) => saved.id == pick.id))
            .toList();
      }
    });
  }

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _threePicks = null;
    });

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
      _luckOffset = Random().nextInt(21) - 10;
      _insightKey++;
      _showReadyFlash = true;
    });

    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showReadyFlash = false);
    });
  }

  Future<void> _generateThreePicks() async {
    setState(() => _isThreePicksLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final picks = List.generate(3, (i) {
      final history = LotteryService.instance
          .getRecentDraws(_selectedLottery.id, limit: _kThreePicksWindows[i]);
      return GeneratorService.instance.generate(
        lottery: _selectedLottery,
        style: _kThreePicksStyles[i],
        history: history,
      );
    });

    final diversified = _diversifyBonusBalls(picks);

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _threePicks = diversified;
      _threePicksSaved = [false, false, false];
      _pick = null;
      _isSaved = false;
      _isThreePicksLoading = false;
    });

    unawaited(AnalyticsService.logGenerateNumbers(
      lottery: _selectedLottery.id,
      strategy: 'three_picks',
      pickCount: 3,
      source: 'home_inline',
    ));
  }

  List<GeneratedPick> _diversifyBonusBalls(List<GeneratedPick> picks) {
    if (!_selectedLottery.hasBonus) return picks;
    // Supplementary lotteries (Saturday, Oz Lotto) have multiple supp numbers
    // per pick — diversification doesn't apply; return as-is to avoid truncation.
    if (_selectedLottery.bonusIsSupplementary) return picks;

    final min = _selectedLottery.bonusMin!;
    final max = _selectedLottery.bonusMax!;
    final used = <int>{};
    final pool = ([for (var i = min; i <= max; i++) i]..shuffle());

    return picks.map((pick) {
      if (pick.bonusNumbers == null || pick.bonusNumbers!.isEmpty) return pick;
      var bonus = pick.bonusNumbers!.first;
      if (used.contains(bonus)) {
        final replacement =
            pool.firstWhere((n) => !used.contains(n), orElse: () => bonus);
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

  static final _insightMessages = {
    PlayStyle.balanced: [
      'Smart analysis sees a balanced spread for today',
      'History points to an even distribution',
      'Balanced picks look stronger today',
    ],
    PlayStyle.hot: [
      'Recent pattern observed',
      'Frequently seen in recent results',
      'Smart analysis detects a frequent-number pattern',
    ],
    PlayStyle.cold: [
      'Smart analysis found less-frequent numbers ❄️',
      'Less-frequent numbers from past results',
      'Less-frequent numbers from past results',
    ],
    PlayStyle.random: [
      'Sometimes randomness is fun 🎲',
      'Chaos is a pattern too',
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
    final pickToSave = GeneratedPick(
      id: _pick!.id,
      lotteryId: _pick!.lotteryId,
      style: _pick!.style,
      mainNumbers: _pick!.mainNumbers,
      bonusNumbers: _pick!.bonusNumbers,
      createdAt: _pick!.createdAt,
      drawDate: nextDrawDate(_selectedLottery.id),
      drawLabel: nextDrawLabel(_selectedLottery.id),
    );
    await Future.wait([
      LocalStorageService.instance.saveLastPick(pickToSave),
      LocalStorageService.instance.savePickToHistory(pickToSave),
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

  Future<void> _saveThreePick(int index) async {
    HapticFeedback.lightImpact();
    final pick = _threePicks![index];
    await LocalStorageService.instance.savePickToHistory(GeneratedPick(
      id: pick.id,
      lotteryId: pick.lotteryId,
      style: pick.style,
      mainNumbers: pick.mainNumbers,
      bonusNumbers: pick.bonusNumbers,
      createdAt: pick.createdAt,
      pickLabel: _kThreePicksLabels[index],
      drawDate: nextDrawDate(_selectedLottery.id),
      drawLabel: nextDrawLabel(_selectedLottery.id),
    ));
    if (!mounted) return;
    setState(() => _threePicksSaved[index] = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Pick saved'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _saveAllThreePicks() async {
    HapticFeedback.lightImpact();
    if (_threePicksSaved.every((s) => s)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Already saved'), duration: Duration(seconds: 2)),
      );
      return;
    }
    final drawDate = nextDrawDate(_selectedLottery.id);
    final drawLabel = nextDrawLabel(_selectedLottery.id);
    await Future.wait([
      for (var i = 0; i < _threePicks!.length; i++)
        if (!_threePicksSaved[i])
          LocalStorageService.instance.savePickToHistory(GeneratedPick(
            id: _threePicks![i].id,
            lotteryId: _threePicks![i].lotteryId,
            style: _threePicks![i].style,
            mainNumbers: _threePicks![i].mainNumbers,
            bonusNumbers: _threePicks![i].bonusNumbers,
            createdAt: _threePicks![i].createdAt,
            pickLabel: _kThreePicksLabels[i],
            drawDate: drawDate,
            drawLabel: drawLabel,
          )),
    ]);
    if (!mounted) return;
    setState(() => _threePicksSaved = [true, true, true]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('All 3 picks saved'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnyLoading = _isLoading || _isThreePicksLoading;

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
                    text: 'NumberRun ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '',
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
              'Number sets from past records',
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
            onPressed: () async {
              final loaded = await Navigator.push<GeneratedPick>(
                context,
                MaterialPageRoute(builder: (_) => const SavedPicksScreen()),
              );
              if (loaded != null && mounted) {
                final lottery = kSeedLotteries.firstWhere(
                  (l) => l.id == loaded.lotteryId,
                  orElse: () => kSeedLotteries.first,
                );
                setState(() {
                  _selectedLottery = lottery;
                  _pick = loaded;
                  _isSaved = true;
                  _isPickExpanded = false;
                  _threePicks = null;
                });
              } else {
                await _syncSavedFlags();
              }
            },
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
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DisclaimerCard(),
            const SizedBox(height: 16),

            // ── Lottery selector ──────────────────────────────────
            Text('Number selection', style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            InputDecorator(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Lottery>(
                  value: _selectedLottery,
                  isExpanded: true,
                  items: kSeedLotteries.map((l) {
                    return DropdownMenuItem(
                        value: l, child: Text(l.displayName));
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
                      _threePicks = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Luck bar ──────────────────────────────────────────
            _LuckBar(
              lottery: _selectedLottery,
              luckOffset: _luckOffset,
              streak: _streak,
            ),
            const SizedBox(height: 20),

            // ── Smart picker card ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.black.withAlpha(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number Picks',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose one style, or generate 3 number sets',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 18),

                  // Generate 1 Pick (outlined, secondary)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: isAnyLoading ? null : _generate,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(
                            color: theme.colorScheme.primary.withAlpha(71)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.colorScheme.primary),
                            )
                          : Text(
                              'Generate 1 Pick',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✨ Generate 3 Smart Picks (filled primary hero)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: isAnyLoading ? null : _generateThreePicks,
                      icon: _isThreePicksLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: Text(
                        _isThreePicksLoading
                            ? 'Generating…'
                            : '🎲 Generate 3 Number Sets',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shadowColor: theme.colorScheme.primary.withAlpha(80),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '3 Number Sets combine Balanced + Popular + Random for variety.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withAlpha(110),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✨ Some selections overlapped multiple numbers in recent past results 👀',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.primary.withAlpha(160),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Results ───────────────────────────────────────────
            if (_threePicks != null)
              _ThreePicksInline(
                picks: _threePicks!,
                labels: _kThreePicksLabels,
                badges: _kThreePicksBadges,
                microcopy: _kThreePicksMicrocopy,
                colors: _kThreePicksColors,
                lottery: _selectedLottery,
                savedStates: _threePicksSaved,
                onSave: _saveThreePick,
                onSaveAll: _saveAllThreePicks,
              )
            else ...[
              // AI insight line
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
                                    ? '✨ Your Smart pick is ready'
                                    : _insightText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _showReadyFlash
                                      ? Colors.green.shade400
                                      : theme.colorScheme.primary
                                          .withAlpha(200),
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

              // Single pick result
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                        parent: animation, curve: Curves.easeOutCubic)),
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
                                color:
                                    theme.colorScheme.onSurface.withAlpha(55)),
                            const SizedBox(height: 12),
                            Text(
                              'Generate a number set from past records 🎲',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withAlpha(130),
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
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Three picks inline result ─────────────────────────────────────────────────

class _ThreePicksInline extends StatefulWidget {
  final List<GeneratedPick> picks;
  final List<String> labels;
  final List<String> badges;
  final List<String> microcopy;
  final List<Color> colors;
  final Lottery lottery;
  final List<bool> savedStates;
  final void Function(int index) onSave;
  final VoidCallback onSaveAll;

  const _ThreePicksInline({
    required this.picks,
    required this.labels,
    required this.badges,
    required this.microcopy,
    required this.colors,
    required this.lottery,
    required this.savedStates,
    required this.onSave,
    required this.onSaveAll,
  });

  @override
  State<_ThreePicksInline> createState() => _ThreePicksInlineState();
}

class _ThreePicksInlineState extends State<_ThreePicksInline> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.picks.length; i++) ...[
          _InlinePickCard(
            pick: widget.picks[i],
            label: widget.labels[i],
            badge: widget.badges[i],
            microcopy: widget.microcopy[i],
            accentColor: widget.colors[i],
            lottery: widget.lottery,
            isSaved: widget.savedStates[i],
            onSave: () => widget.onSave(i),
          ),
          if (i < widget.picks.length - 1) const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onSaveAll,
            icon: const Icon(Icons.bookmark_rounded, size: 18),
            label: const Text('Save All'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Inline pick card ──────────────────────────────────────────────────────────

class _InlinePickCard extends StatelessWidget {
  final GeneratedPick pick;
  final String label;
  final String badge;
  final String microcopy;
  final Color accentColor;
  final Lottery lottery;
  final bool isSaved;
  final VoidCallback onSave;

  const _InlinePickCard({
    required this.pick,
    required this.label,
    required this.badge,
    required this.microcopy,
    required this.accentColor,
    required this.lottery,
    required this.isSaved,
    required this.onSave,
  });

  String _buildCopyText() {
    final main = pick.mainNumbers.join('  ');
    final bonus =
        (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
            ? ' + ${pick.bonusNumbers!.join(' ')}'
            : '';
    return '$label\n${lottery.name}: $main$bonus\nGenerated for fun — NumberRun 🎯';
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildCopyText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _share(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await showPickShareSheet(
      context: btnCtx,
      pick: pick,
      lottery: lottery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withAlpha(13)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withAlpha(25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Label + badge ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: accentColor.withAlpha(30),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Ball row ─────────────────────────────────────────
                    BallRow(
                      mainNumbers: pick.mainNumbers,
                      bonusNumbers: pick.bonusNumbers ?? [],
                      bonusLabel: lottery.bonusLabel,
                      ballSize: 38,
                      spacing: 6,
                    ),
                    const SizedBox(height: 12),

                    // ── Microcopy ────────────────────────────────────────
                    Text(
                      microcopy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Actions ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (btnCtx) => FilledButton.icon(
                              onPressed: () => _share(btnCtx),
                              icon: const Icon(Icons.share_rounded, size: 14),
                              label: const Text('Share'),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                textStyle: const TextStyle(fontSize: 12),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copy(context),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              textStyle: const TextStyle(fontSize: 12),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSaved ? null : onSave,
                            icon: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline_rounded,
                              size: 14,
                            ),
                            label: Text(isSaved ? 'Saved ✓' : 'Save'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              textStyle: const TextStyle(fontSize: 12),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Luck bar ──────────────────────────────────────────────────────────────────

class _LuckBar extends StatelessWidget {
  final Lottery lottery;
  final int luckOffset;
  final int streak;

  const _LuckBar({
    required this.lottery,
    this.luckOffset = 0,
    this.streak = 0,
  });

  int get _luckPct {
    final d = DateTime.now().toLocal();
    final seed = d.year * 10000 + d.month * 100 + d.day;
    final base = 65 + Random(seed).nextInt(28);
    return (base + luckOffset).clamp(50, 99);
  }

  String _nextDraw() {
    final auWeekday = switch (lottery.id) {
      'au_powerball' => DateTime.thursday,
      'au_ozlotto' => DateTime.tuesday,
      'au_saturday' => DateTime.saturday,
      _ => null,
    };
    if (auWeekday != null) {
      final now =
          DateTime.now().toUtc().add(const Duration(hours: 10));
      var next = now;
      while (next.weekday != auWeekday) {
        next = next.add(const Duration(days: 1));
      }
      if (next.day == now.day &&
          (now.hour > 20 || (now.hour == 20 && now.minute >= 30))) {
        next = next.add(const Duration(days: 7));
      }
      final diff = next.difference(now);
      if (diff.inDays >= 2) return 'Next result update in ${diff.inDays}d';
      if (diff.inHours >= 1) return 'Next result update in ${diff.inHours}h';
      return 'Result update soon!';
    }

    final usDrawDays = switch (lottery.id) {
      'us_powerball' => [
          DateTime.monday,
          DateTime.wednesday,
          DateTime.saturday
        ],
      'us_megamillions' => [DateTime.tuesday, DateTime.friday],
      _ => null,
    };
    if (usDrawDays != null) {
      final now =
          DateTime.now().toUtc().subtract(const Duration(hours: 5));
      DateTime? nearest;
      for (final weekday in usDrawDays) {
        var candidate = now;
        while (candidate.weekday != weekday) {
          candidate = candidate.add(const Duration(days: 1));
        }
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
        if (diff.inDays >= 2) return 'Next result update in ${diff.inDays}d';
        if (diff.inHours >= 1) return 'Next result update in ${diff.inHours}h';
        return 'Result update soon!';
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

    return Row(
      children: [
        Text(
          '📊 Similarity score: $_luckPct / 100',
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
    );
  }
}

// ── Compact pick banner ───────────────────────────────────────────────────────

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
    await showPickShareSheet(
      context: btnCtx,
      pick: widget.pick,
      lottery: widget.lottery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainNums = widget.pick.mainNumbers;
    final bonusNums = widget.pick.bonusNumbers ?? [];
    final total = mainNums.length + bonusNums.length;

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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Smart Pick · ${widget.pick.style.tagline}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        Builder(
                          builder: (btnCtx) => FilledButton.icon(
                            onPressed: () => _shareCard(btnCtx),
                            icon:
                                const Icon(Icons.share_rounded, size: 14),
                            label: const Text('Share'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              for (var i = 0; i < mainNums.length; i++) ...[
                                AnimatedBuilder(
                                  animation: _ballAnim(i, total),
                                  builder: (_, child) => Transform.scale(
                                    scale: _ballAnim(i, total).value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                  child: LottoBall(number: mainNums[i], size: 38),
                                ),
                                if (i < mainNums.length - 1 ||
                                    (bonusNums.isNotEmpty && !widget.lottery.bonusIsSupplementary))
                                  const SizedBox(width: 6),
                              ],
                              // Powerball-style: inline
                              if (bonusNums.isNotEmpty && !widget.lottery.bonusIsSupplementary) ...[
                                const SizedBox(width: 2),
                                for (var i = 0; i < bonusNums.length; i++) ...[
                                  AnimatedBuilder(
                                    animation: _ballAnim(mainNums.length + i, total),
                                    builder: (_, child) => Transform.scale(
                                      scale: _ballAnim(mainNums.length + i, total).value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                    child: LottoBall(number: bonusNums[i], isBonus: true, size: 38),
                                  ),
                                  if (i < bonusNums.length - 1) const SizedBox(width: 6),
                                ],
                              ],
                            ],
                          ),
                        ),
                        // Supplementary-style: second row
                        if (bonusNums.isNotEmpty && widget.lottery.bonusIsSupplementary) ...[
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Supp',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFD32F2F),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                for (var i = 0; i < bonusNums.length; i++) ...[
                                  AnimatedBuilder(
                                    animation: _ballAnim(mainNums.length + i, total),
                                    builder: (_, child) => Transform.scale(
                                      scale: _ballAnim(mainNums.length + i, total).value.clamp(0.0, 1.0),
                                      child: child,
                                    ),
                                    child: LottoBall(number: bonusNums[i], isBonus: true, size: 34),
                                  ),
                                  if (i < bonusNums.length - 1) const SizedBox(width: 6),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
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
