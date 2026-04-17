import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/generated_pick.dart';
import '../services/local_storage_service.dart';
import '../services/lottery_service.dart';
import '../widgets/lotto_ball.dart';

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

// ── Screen ────────────────────────────────────────────────────────────────────

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

  Future<void> _delete(GeneratedPick pick) async {
    await LocalStorageService.instance.deleteSavedPickById(pick.id);
    setState(() => _picks.removeWhere((p) => p.id == pick.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick deleted'), duration: Duration(seconds: 2)),
      );
    }
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

  Widget _buildGroupedList(ThemeData theme) {
    final grouped = _groupByCountry();
    final sections = _countryOrder.where(grouped.containsKey).toList();

    final items = <Widget>[];

    // "Newest first" indicator
    items.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.access_time_rounded,
              size: 13, color: theme.colorScheme.onSurface.withAlpha(100)),
          const SizedBox(width: 4),
          Text(
            'Newest first',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    ));

    for (final country in sections) {
      final picks = grouped[country]!;
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

class _PickItem extends StatelessWidget {
  final GeneratedPick pick;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _PickItem({
    required this.pick,
    required this.onDelete,
    required this.onTap,
  });

  String get _lotteryName {
    final l = LotteryService.instance.getLotteryById(pick.lotteryId);
    return l?.name ?? pick.lotteryId;
  }

  String get _shareText {
    final main = pick.mainNumbers.join('  ');
    final bonusLabel = switch (pick.lotteryId) {
      'us_powerball' => 'Powerball',
      'us_megamillions' => 'Mega Ball',
      _ => 'Bonus',
    };
    final bonus = (pick.bonusNumbers != null && pick.bonusNumbers!.isNotEmpty)
        ? '\n+ $bonusLabel: ${pick.bonusNumbers!.join(' ')}'
        : '';
    return '🎯 My AI $_lotteryName Pick\n${pick.displayLabel}\n\n$main$bonus\n\nGenerated for fun — LottoRun AI';
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _shareText));
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
    await Share.share(_shareText, sharePositionOrigin: origin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('d MMM yyyy · HH:mm').format(pick.createdAt.toLocal());
    final bonusNums = pick.bonusNumbers ?? [];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
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
                          _lotteryName,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pick.displayLabel,
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
                      .map((n) => LottoBall(number: n, size: 36)),
                  ...bonusNums.map(
                      (n) => LottoBall(number: n, isBonus: true, size: 36)),
                ],
              ),

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
                        onPressed: () => _share(btnCtx),
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
                      onPressed: onTap,
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
    );
  }
}
