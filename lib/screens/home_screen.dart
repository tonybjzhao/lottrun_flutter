import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../data/seed_lotteries.dart';
import '../services/generator_service.dart';
import '../services/lottery_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/disclaimer_card.dart';
import '../widgets/lotto_ball.dart';
import '../widgets/result_panel.dart';
import '../widgets/style_chip_group.dart';
import 'history_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _restorePrefs();
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

    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pick = pick;
      _isSaved = false;
      _isLoading = false;
      _isPickExpanded = false;
    });
  }

  Future<void> _savePick() async {
    if (_pick == null) return;
    HapticFeedback.lightImpact();
    await LocalStorageService.instance.saveLastPick(_pick!);
    if (!mounted) return;
    setState(() => _isSaved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick saved locally.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Lott',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              TextSpan(
                text: 'Fun',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.secondaryContainer,
                ),
              ),
            ],
          ),
        ),
        actions: [
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
              onChanged: (s) => setState(() => _selectedStyle = s),
            ),
            const SizedBox(height: 24),

            // ── Generate buttons ──────────────────────────────────
            FilledButton.icon(
              onPressed: _isLoading ? null : _generate,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.casino_rounded),
              label: Text(
                _isLoading ? 'Generating…' : 'Try My Luck',
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _showThreePicks,
              icon: const Icon(Icons.filter_3_rounded, size: 18),
              label: const Text('Generate 3 Picks'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

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
    });
    _animController
      ..reset()
      ..forward();
  }

  String _buildCopyAll() {
    final lines = <String>[
      'LottFun · ${widget.style.label} · ${widget.lottery.name}',
    ];
    for (var i = 0; i < _picks.length; i++) {
      final p = _picks[i];
      final main = p.mainNumbers.join('  ');
      final bonus = (p.bonusNumbers != null && p.bonusNumbers!.isNotEmpty)
          ? '  |  PB ${p.bonusNumbers!.join(' ')}'
          : '';
      lines.add('Pick ${i + 1}: $main$bonus');
    }
    lines.add('Generated for fun — LottFun');
    return lines.join('\n');
  }

  Future<void> _copyAll() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildCopyAll()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All 3 picks copied to clipboard.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                    label: 'Pick ${i + 1} · ${_picks[i].style.tagline}',
                    lottery: widget.lottery,
                  ),
                );
              },
            ),
          ),

          // ── Copy All button ─────────────────────────────────────
          SafeArea(
            minimum: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: FilledButton.icon(
                onPressed: _copyAll,
                icon: const Icon(Icons.copy_all_rounded, size: 18),
                label: const Text('Copy All Picks'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact pick banner (home screen lightweight preview) ─────────────────────

class _CompactPickBanner extends StatelessWidget {
  final GeneratedPick pick;
  final VoidCallback onExpand;

  const _CompactPickBanner({
    super.key,
    required this.pick,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onExpand,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Label row ─────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Quick Pick · ${pick.style.tagline}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ── Balls ──────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...pick.mainNumbers.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: LottoBall(number: n, size: 34),
                        ),
                      ),
                      if (pick.bonusNumbers != null &&
                          pick.bonusNumbers!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        ...pick.bonusNumbers!.map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: LottoBall(number: n, isBonus: true, size: 34),
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
    );
  }
}

// ── Mini pick card ────────────────────────────────────────────────────────────

class _MiniPickCard extends StatelessWidget {
  final GeneratedPick pick;
  final String label;
  final Lottery lottery;

  const _MiniPickCard({
    required this.pick,
    required this.label,
    required this.lottery,
  });

  String _buildCopyText() {
    final main = pick.mainNumbers.join('  ');
    final bonus = (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        ? '  |  PB ${pick.bonusNumbers!.join(' ')}'
        : '';
    return '$label · ${pick.style.label} · ${lottery.name}\n$main$bonus\nGenerated for fun — LottFun';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
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
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...pick.mainNumbers
                    .map((n) => LottoBall(number: n, size: 38)),
                if (pick.bonusNumbers != null)
                  ...pick.bonusNumbers!.map(
                      (n) => LottoBall(number: n, isBonus: true, size: 38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
