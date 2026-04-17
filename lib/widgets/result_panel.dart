import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import 'lotto_ball.dart';
import 'pick_share_card.dart';

class ResultPanel extends StatefulWidget {
  final GeneratedPick pick;
  final Lottery lottery;
  final LotteryDraw? recentDraw;
  final VoidCallback onSave;
  final bool isSaved;
  final VoidCallback? onCollapse;

  const ResultPanel({
    super.key,
    required this.pick,
    required this.lottery,
    this.recentDraw,
    required this.onSave,
    this.isSaved = false,
    this.onCollapse,
  });

  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final totalBalls = widget.pick.mainNumbers.length +
        (widget.pick.bonusNumbers?.length ?? 0);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + totalBalls * 70),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Each ball gets a staggered Interval within [0, 1]
  Animation<double> _ballAnim(int index, int total) {
    final step = 0.65 / total;
    final start = index * step;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.elasticOut),
    );
  }

  Widget _animBall(int number, bool isBonus, int index, int total) {
    final anim = _ballAnim(index, total);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Transform.scale(
        scale: anim.value.clamp(0.0, 1.0),
        child: child,
      ),
      child: LottoBall(number: number, isBonus: isBonus),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _buildCopyText() {
    final main = widget.pick.mainNumbers.join('  ');
    final lines = <String>[
      '${widget.pick.style.label} · ${widget.lottery.name}',
      main,
      if (widget.pick.bonusNumbers != null && widget.pick.bonusNumbers!.isNotEmpty)
        'Powerball: ${widget.pick.bonusNumbers!.join(' ')}',
      'Generated for fun — LottoRun AI',
    ];
    return lines.join('\n');
  }

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _buildCopyText()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareCard(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await sharePickCard(repaintKey: _shareCardKey, btnContext: btnCtx);
  }

  // ── Match check ──────────────────────────────────────────────────────────

  Widget? _buildMatchRow(ThemeData theme) {
    if (widget.recentDraw == null) return null;
    final draw = widget.recentDraw!;
    final matched = widget.pick.mainNumbers
        .where((n) => draw.mainNumbers.contains(n))
        .toList();
    final bonusHit = widget.pick.bonusNumbers != null &&
        draw.bonusNumbers != null &&
        widget.pick.bonusNumbers!.any((n) => draw.bonusNumbers!.contains(n));
    final dateStr = DateFormat('d MMM yyyy').format(draw.drawDate);

    String label;
    Color color;
    if (matched.length >= 5 || (matched.length >= 4 && bonusHit)) {
      label = '🎯 Incredible — ${matched.length}${bonusHit ? ' + PB' : ''} matched last draw ($dateStr)';
      color = Colors.green.shade700;
    } else if (matched.length >= 3) {
      label = '😮 So close — ${matched.length}${bonusHit ? ' + PB' : ''} matched last draw ($dateStr)';
      color = theme.colorScheme.primary;
    } else if (matched.length == 2) {
      label = '🙌 Almost — 2 matched last draw ($dateStr)';
      color = theme.colorScheme.onSurface.withAlpha(160);
    } else if (matched.length == 1) {
      label = '1 matched last draw ($dateStr) — keep trying';
      color = theme.colorScheme.onSurface.withAlpha(140);
    } else {
      label = '0 matched last draw ($dateStr) — luck is building';
      color = theme.colorScheme.onSurface.withAlpha(100);
    }

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: matched.length >= 3 ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        DateFormat('d MMM yyyy · HH:mm').format(widget.pick.createdAt);
    final matchRow = _buildMatchRow(theme);

    final mainNums = widget.pick.mainNumbers;
    final bonusNums = widget.pick.bonusNumbers ?? [];
    final total = mainNums.length + bonusNums.length;

    return Stack(
      children: [
        Offstage(
          child: RepaintBoundary(
            key: _shareCardKey,
            child: PickShareCard(pick: widget.pick, lottery: widget.lottery),
          ),
        ),
        Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emotional tagline ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.pick.style.tagline} · ${widget.lottery.name}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.pick.style.taglineSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onCollapse != null)
                  IconButton(
                    onPressed: widget.onCollapse,
                    icon: const Icon(Icons.keyboard_arrow_up_rounded),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Collapse',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Main balls (staggered pop-in) ──────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < mainNums.length; i++)
                  _animBall(mainNums[i], false, i, total),
              ],
            ),

            // ── Bonus ball ─────────────────────────────────────
            if (bonusNums.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Powerball',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFFD32F2F),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  for (var i = 0; i < bonusNums.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _animBall(
                          bonusNums[i], true, mainNums.length + i, total),
                    ),
                ],
              ),
            ],

            // ── Match check ────────────────────────────────────
            if (matchRow != null) ...[
              const SizedBox(height: 10),
              matchRow,
            ],

            // ── Disclaimer ─────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              'Generated for fun using historical patterns.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
                fontStyle: FontStyle.italic,
              ),
            ),

            // ── Actions ────────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              timeStr,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(80),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(context),
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('Copy'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Builder(
                    builder: (btnCtx) => OutlinedButton.icon(
                      onPressed: () => _shareCard(btnCtx),
                      icon: const Icon(Icons.share_rounded, size: 15),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.isSaved ? null : widget.onSave,
                    icon: Icon(
                      widget.isSaved ? Icons.check : Icons.bookmark_outline,
                      size: 15,
                    ),
                    label: Text(widget.isSaved ? 'Saved' : 'Save'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ), // Card
      ],
    ); // Stack
  }
}
