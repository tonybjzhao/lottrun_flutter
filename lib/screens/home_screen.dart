import 'package:flutter/material.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../data/seed_lotteries.dart';
import '../services/generator_service.dart';
import '../services/lottery_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/disclaimer_card.dart';
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

            // ── Generate button ───────────────────────────────────
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
                          const SizedBox(height: 4),
                          Text(
                            '基于真实开奖数据，试试一组有趣的号码 🎲',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withAlpha(100),
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
