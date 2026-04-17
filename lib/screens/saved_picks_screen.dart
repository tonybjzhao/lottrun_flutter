import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../services/local_storage_service.dart';
import '../services/lottery_service.dart';
import '../widgets/lotto_ball.dart';

class SavedPicksScreen extends StatefulWidget {
  const SavedPicksScreen({super.key});

  @override
  State<SavedPicksScreen> createState() => _SavedPicksScreenState();
}

class _SavedPicksScreenState extends State<SavedPicksScreen> {
  List<GeneratedPick> _picks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final picks = await LocalStorageService.instance.getSavedPicks();
    if (mounted) setState(() { _picks = picks; _loading = false; });
  }

  Future<void> _delete(int index) async {
    await LocalStorageService.instance.deleteSavedPickAt(index);
    setState(() => _picks.removeAt(index));
  }

  String _shareText(GeneratedPick pick) {
    final lottery = LotteryService.instance.getLotteryById(pick.lotteryId);
    final name = lottery?.name ?? pick.lotteryId;
    final main = pick.mainNumbers.join('  ');
    final bonusLabel = switch (pick.lotteryId) {
      'us_powerball' => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _ => 'Bonus',
    };
    final bonus = (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        ? '\n+ $bonusLabel: ${pick.bonusNumbers!.join(' ')}'
        : '';
    return '🎯 My AI $name Pick\n${pick.style.tagline}\n\n$main$bonus\n\nGenerated for fun — LottoRun AI';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Picks'),
        actions: [
          if (_picks.isNotEmpty)
            TextButton(
              onPressed: () async {
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
                  for (var i = _picks.length - 1; i >= 0; i--) {
                    await LocalStorageService.instance.deleteSavedPickAt(0);
                  }
                  setState(() => _picks.clear());
                }
              },
              child: Text(
                'Clear all',
                style: TextStyle(color: theme.colorScheme.error),
              ),
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
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: _picks.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) =>
                      _PickItem(
                        pick: _picks[i],
                        onDelete: () => _delete(i),
                        shareText: _shareText(_picks[i]),
                      ),
                ),
    );
  }
}

// ── Single saved pick card ────────────────────────────────────────────────────

class _PickItem extends StatelessWidget {
  final GeneratedPick pick;
  final VoidCallback onDelete;
  final String shareText;

  const _PickItem({
    required this.pick,
    required this.onDelete,
    required this.shareText,
  });

  String get _lotteryName {
    final l = LotteryService.instance.getLotteryById(pick.lotteryId);
    return l?.name ?? pick.lotteryId;
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: shareText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copied to clipboard.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _share(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    final box = btnCtx.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    await Share.share(shareText, sharePositionOrigin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('d MMM yyyy · HH:mm').format(pick.createdAt.toLocal());
    final bonusNums = pick.bonusNumbers ?? [];

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
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
                      Text(
                        '${pick.style.tagline} · $_lotteryName',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(110),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: theme.colorScheme.onSurface.withAlpha(120),
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Balls ───────────────────────────────────────────
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...pick.mainNumbers
                    .map((n) => LottoBall(number: n, size: 38)),
                ...bonusNums.map(
                    (n) => LottoBall(number: n, isBonus: true, size: 38)),
              ],
            ),

            const SizedBox(height: 10),

            // ── Actions ─────────────────────────────────────────
            Row(
              children: [
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
                  builder: (btnCtx) => TextButton.icon(
                    onPressed: () => _share(btnCtx),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
