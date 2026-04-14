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
    final history =
        LotteryService.instance.getRecentDraws(_selectedLottery.id, limit: 100);
    final picks = List.generate(
      3,
      (_) => GeneratorService.instance.generate(
        lottery: _selectedLottery,
        style: _selectedStyle,
        history: history,
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '3 Picks · ${_selectedLottery.name}',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: picks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _MiniPickCard(
                  pick: picks[i],
                  label: 'Pick ${i + 1}',
                  lottery: _selectedLottery,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);

    // Brief pause so the "Generating…" state is visible / feels intentional
    await Future.delayed(const Duration(milliseconds: 700));

    final history = LotteryService.instance
        .getRecentDraws(_selectedLottery.id, limit: 100);

    final pick = GeneratorService.instance.generate(
      lottery: _selectedLottery,
      style: _selectedStyle,
      history: history,
    );

    await LocalStorageService.instance.saveLastLotteryId(_selectedLottery.id);
    await LocalStorageService.instance.saveLastStyle(_selectedStyle);

    if (!mounted) return;
    setState(() {
      _pick = pick;
      _isSaved = false;
      _isLoading = false;
    });
  }

  Future<void> _savePick() async {
    if (_pick == null) return;
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
                builder: (_) =>
                    HistoryScreen(lottery: _selectedLottery),
              ),
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
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                _isLoading ? 'Generating…' : 'Generate Numbers',
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
              transitionBuilder: (child, animation) {
                return FadeTransition(
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
                );
              },
              child: _pick != null
                  ? ResultPanel(
                      key: ValueKey(_pick!.createdAt),
                      pick: _pick!,
                      lottery: _selectedLottery,
                      onSave: _savePick,
                      isSaved: _isSaved,
                    )
                  : Padding(
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
                            'Try a fun pick based on real draw history 🎲',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withAlpha(130),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 80), // space for ad banner
          ],
        ),
      ),

      // ── Ad banner placeholder ─────────────────────────────────
      bottomNavigationBar: Container(
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
    );
  }
}

// ── Mini pick card used in the "3 Picks" bottom sheet ─────────────────────────

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
    final lines = <String>[
      '$label · ${pick.style.label} · ${lottery.name}',
      main,
      if (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        'Powerball: ${pick.bonusNumbers!.join(' ')}',
      'Generated for fun — LottFun',
    ];
    return lines.join('\n');
  }

  Future<void> _copy(BuildContext context) async {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                GestureDetector(
                  onTap: () => _copy(context),
                  child: Icon(Icons.copy_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withAlpha(130)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...pick.mainNumbers
                    .map((n) => LottoBall(number: n, size: 38)),
                if (pick.bonusNumbers != null)
                  ...pick.bonusNumbers!
                      .map((n) => LottoBall(number: n, isBonus: true, size: 38)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
