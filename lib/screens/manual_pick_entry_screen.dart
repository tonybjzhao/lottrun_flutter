import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/seed_lotteries.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../services/draw_date_service.dart';
import '../services/local_storage_service.dart';

class ManualPickEntryScreen extends StatefulWidget {
  final Lottery? initialLottery;

  const ManualPickEntryScreen({super.key, this.initialLottery});

  @override
  State<ManualPickEntryScreen> createState() => _ManualPickEntryScreenState();
}

class _ManualPickEntryScreenState extends State<ManualPickEntryScreen> {
  late Lottery _lottery;
  final Set<int> _selectedMain = {};
  final Set<int> _selectedBonus = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lottery = widget.initialLottery ?? kSeedLotteries.first;
  }

  void _onLotteryChanged(Lottery? l) {
    if (l == null) return;
    setState(() {
      _lottery = l;
      _selectedMain.clear();
      _selectedBonus.clear();
    });
  }

  bool get _isComplete =>
      _selectedMain.length == _lottery.mainCount &&
      (!_lottery.hasBonus ||
          _selectedBonus.length == (_lottery.bonusCount ?? 0));

  void _toggleMain(int n) {
    setState(() {
      if (_selectedMain.contains(n)) {
        _selectedMain.remove(n);
      } else if (_selectedMain.length < _lottery.mainCount) {
        _selectedMain.add(n);
      }
    });
  }

  void _toggleBonus(int n) {
    final limit = _lottery.bonusCount ?? 1;
    setState(() {
      if (_selectedBonus.contains(n)) {
        _selectedBonus.remove(n);
      } else if (_selectedBonus.length < limit) {
        _selectedBonus.add(n);
      }
    });
  }

  Future<void> _save() async {
    if (!_isComplete || _saving) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final mainSorted = _selectedMain.toList()..sort();
    final bonusSorted = _selectedBonus.isEmpty ? null : (_selectedBonus.toList()..sort());
    final now = DateTime.now();

    final pick = GeneratedPick(
      lotteryId: _lottery.id,
      style: PlayStyle.balanced,
      mainNumbers: mainSorted,
      bonusNumbers: bonusSorted,
      createdAt: now,
      pickLabel: '👤 My Numbers',
      drawDate: nextDrawDate(_lottery.id),
      drawLabel: nextDrawLabel(_lottery.id),
      source: PickSource.manual,
    );

    await LocalStorageService.instance.savePickToHistory(pick);
    if (mounted) Navigator.pop(context, true);
  }

  String _bonusLabel() => _lottery.bonusLabel ?? 'Supp';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add My Numbers')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Lottery selector ──────────────────────────────
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Lottery',
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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

                  // ── Draw info ─────────────────────────────────────
                  if (nextDrawLabel(_lottery.id) != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.event_rounded,
                            size: 13,
                            color: theme.colorScheme.primary.withAlpha(160)),
                        const SizedBox(width: 5),
                        Text(
                          'Tracking result: ${nextDrawLabel(_lottery.id)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary.withAlpha(160),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Main numbers ──────────────────────────────────
                  _SectionHeader(
                    label:
                        'Pick ${_lottery.mainCount} numbers  (${_lottery.mainMin}–${_lottery.mainMax})',
                    selected: _selectedMain.length,
                    total: _lottery.mainCount,
                    theme: theme,
                  ),
                  const SizedBox(height: 10),
                  _NumberGrid(
                    min: _lottery.mainMin,
                    max: _lottery.mainMax,
                    selected: _selectedMain,
                    limit: _lottery.mainCount,
                    isBonus: false,
                    onTap: _toggleMain,
                  ),

                  // ── Bonus numbers ─────────────────────────────────
                  if (_lottery.hasBonus) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(
                      label:
                          'Pick ${_lottery.bonusCount} ${_bonusLabel()}  (${_lottery.bonusMin}–${_lottery.bonusMax})',
                      selected: _selectedBonus.length,
                      total: _lottery.bonusCount!,
                      theme: theme,
                      isBonus: true,
                    ),
                    const SizedBox(height: 10),
                    _NumberGrid(
                      min: _lottery.bonusMin!,
                      max: _lottery.bonusMax!,
                      selected: _selectedBonus,
                      limit: _lottery.bonusCount!,
                      isBonus: true,
                      onTap: _toggleBonus,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Save button ───────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isComplete && !_saving ? _save : null,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.bookmark_add_rounded),
                  label: Text(
                    _isComplete ? 'Save My Numbers' : _progressText(),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _progressText() {
    final mainLeft = _lottery.mainCount - _selectedMain.length;
    if (mainLeft > 0) return 'Pick $mainLeft more number${mainLeft == 1 ? '' : 's'}';
    if (_lottery.hasBonus) {
      final bonusLeft = (_lottery.bonusCount ?? 1) - _selectedBonus.length;
      if (bonusLeft > 0) {
        return 'Pick $bonusLeft more ${_bonusLabel().toLowerCase()}${bonusLeft == 1 ? '' : 's'}';
      }
    }
    return 'Save My Numbers';
  }
}

// ── Section header with progress ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int selected;
  final int total;
  final ThemeData theme;
  final bool isBonus;

  const _SectionHeader({
    required this.label,
    required this.selected,
    required this.total,
    required this.theme,
    this.isBonus = false,
  });

  @override
  Widget build(BuildContext context) {
    final done = selected == total;
    final color = done
        ? Colors.green.shade600
        : isBonus
            ? const Color(0xFFD32F2F)
            : theme.colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: done
              ? Icon(Icons.check_circle_rounded,
                  key: const ValueKey('done'), size: 18, color: Colors.green.shade600)
              : Text(
                  '$selected / $total',
                  key: const ValueKey('count'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(130),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Tappable number grid ──────────────────────────────────────────────────────

class _NumberGrid extends StatelessWidget {
  final int min;
  final int max;
  final Set<int> selected;
  final int limit;
  final bool isBonus;
  final ValueChanged<int> onTap;

  const _NumberGrid({
    required this.min,
    required this.max,
    required this.selected,
    required this.limit,
    required this.isBonus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final full = selected.length >= limit;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var n = min; n <= max; n++)
          _NumberChip(
            number: n,
            selected: selected.contains(n),
            disabled: full && !selected.contains(n),
            isBonus: isBonus,
            theme: theme,
            onTap: () => onTap(n),
          ),
      ],
    );
  }
}

class _NumberChip extends StatelessWidget {
  final int number;
  final bool selected;
  final bool disabled;
  final bool isBonus;
  final ThemeData theme;
  final VoidCallback onTap;

  const _NumberChip({
    required this.number,
    required this.selected,
    required this.disabled,
    required this.isBonus,
    required this.theme,
    required this.onTap,
  });

  Color get _fillColor => isBonus
      ? const Color(0xFFD32F2F)
      : theme.colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? _fillColor : Colors.transparent,
          border: Border.all(
            color: selected
                ? _fillColor
                : disabled
                    ? theme.colorScheme.outline.withAlpha(60)
                    : theme.colorScheme.outline.withAlpha(130),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: number >= 100 ? 10 : 13,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : disabled
                      ? theme.colorScheme.onSurface.withAlpha(60)
                      : theme.colorScheme.onSurface.withAlpha(180),
            ),
          ),
        ),
      ),
    );
  }
}
