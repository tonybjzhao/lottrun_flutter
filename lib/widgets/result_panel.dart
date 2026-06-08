import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../l10n/l10n.dart';
import '../models/generated_pick.dart';
import '../models/lottery.dart';
import '../models/lottery_draw.dart';
import '../services/pick_result_service.dart';
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
    final totalBalls =
        widget.pick.mainNumbers.length +
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

  Widget _animBall(
    int number,
    bool isBonus,
    int index,
    int total, {
    double size = 44,
  }) {
    final anim = _ballAnim(index, total);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) =>
          Transform.scale(scale: anim.value.clamp(0.0, 1.0), child: child),
      child: LottoBall(number: number, isBonus: isBonus, size: size),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _buildCopyText(AppLocalizations l10n) {
    final main = widget.pick.mainNumbers.join('  ');
    final bonusLine =
        (widget.pick.bonusNumbers != null &&
            widget.pick.bonusNumbers!.isNotEmpty)
        ? l10n.copyPickBonusLine(
            _bonusLabel(l10n),
            widget.pick.bonusNumbers!.join(' '),
          )
        : '';
    return l10n.copyPickText(
      widget.lottery.name,
      l10n.playStyleTagline(widget.pick.style),
      main,
      bonusLine,
    );
  }

  String _bonusLabel(AppLocalizations l10n) =>
      widget.lottery.bonusLabel ?? l10n.commonSupp;

  Future<void> _copy(BuildContext context) async {
    HapticFeedback.lightImpact();
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: _buildCopyText(l10n)));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.copiedToClipboard),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareCard(BuildContext btnCtx) async {
    HapticFeedback.lightImpact();
    await showPickShareSheet(
      context: btnCtx,
      pick: widget.pick,
      lottery: widget.lottery,
      result: widget.recentDraw == null
          ? null
          : checkPickResult(widget.pick, widget.lottery, [widget.recentDraw!]),
    );
  }

  // ── Match check ──────────────────────────────────────────────────────────

  Widget? _buildMatchRow(AppLocalizations l10n, ThemeData theme) {
    if (widget.recentDraw == null) return null;
    final draw = widget.recentDraw!;
    final mainMatched = widget.pick.mainNumbers
        .where((n) => draw.mainNumbers.contains(n))
        .toList();
    final suppMatched =
        widget.lottery.bonusIsSupplementary && draw.bonusNumbers != null
        ? widget.pick.mainNumbers
              .where((n) => draw.bonusNumbers!.contains(n))
              .toList()
        : <int>[];
    final matched = {...mainMatched, ...suppMatched}.toList();
    final bonusHit =
        widget.pick.bonusNumbers != null &&
        draw.bonusNumbers != null &&
        widget.pick.bonusNumbers!.any((n) => draw.bonusNumbers!.contains(n));
    final dateStr = DateFormat('d MMM yyyy').format(draw.drawDate);

    final bonusLabel = _bonusLabel(l10n);
    final bonusSuffix = bonusHit ? l10n.bonusSuffix(bonusLabel) : '';
    final String label;
    final Color color;
    if (matched.isEmpty && !bonusHit) {
      label = l10n.resultPanelNoOverlap(dateStr);
      color = theme.colorScheme.onSurface.withAlpha(100);
    } else if (matched.isEmpty) {
      label = l10n.resultPanelBonusAppeared(bonusLabel, dateStr);
      color = theme.colorScheme.onSurface.withAlpha(140);
    } else {
      label = l10n.resultPanelOverlap(matched.length, bonusSuffix, dateStr);
      color = matched.length >= 3
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface.withAlpha(140);
    }

    return Text(
      label,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: matched.length >= 3 || bonusHit
            ? FontWeight.w600
            : FontWeight.normal,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final timeStr = DateFormat(
      'd MMM yyyy · HH:mm',
    ).format(widget.pick.createdAt);
    final matchRow = _buildMatchRow(l10n, theme);

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
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                            '${l10n.playStyleTagline(widget.pick.style)} · ${widget.lottery.name}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.playStyleSubtitle(widget.pick.style),
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
                        tooltip: l10n.collapseTooltip,
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Balls (staggered pop-in, horizontal scroll) ────
                if (widget.lottery.bonusIsSupplementary &&
                    bonusNums.isNotEmpty) ...[
                  // Supplementary: two rows (main row + Supp row)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (var i = 0; i < mainNums.length; i++) ...[
                          _animBall(mainNums[i], false, i, total),
                          if (i < mainNums.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.commonSupp,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        for (var i = 0; i < bonusNums.length; i++) ...[
                          _animBall(
                            bonusNums[i],
                            true,
                            mainNums.length + i,
                            total,
                            size: 38,
                          ),
                          if (i < bonusNums.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  // Inline: powerball-style, all on one row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var i = 0; i < mainNums.length; i++) ...[
                            _animBall(mainNums[i], false, i, total),
                            SizedBox(
                              width:
                                  i < mainNums.length - 1 ||
                                      bonusNums.isNotEmpty
                                  ? 8
                                  : 0,
                            ),
                          ],
                          if (bonusNums.isNotEmpty) ...[
                            Text(
                              _bonusLabel(l10n),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color(0xFFD32F2F),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            for (var i = 0; i < bonusNums.length; i++) ...[
                              _animBall(
                                bonusNums[i],
                                true,
                                mainNums.length + i,
                                total,
                              ),
                              if (i < bonusNums.length - 1)
                                const SizedBox(width: 8),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Match check ────────────────────────────────────
                if (matchRow != null) ...[const SizedBox(height: 10), matchRow],

                // ── Disclaimer ─────────────────────────────────────
                const SizedBox(height: 10),
                Text(
                  l10n.generatedForFunHistoricalPatterns,
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
                      child: Builder(
                        builder: (btnCtx) => FilledButton.icon(
                          onPressed: () => _shareCard(btnCtx),
                          icon: const Icon(Icons.share_rounded, size: 15),
                          label: Text(l10n.commonShare),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copy(context),
                        icon: const Icon(Icons.copy_rounded, size: 15),
                        label: Text(l10n.commonCopy),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          textStyle: const TextStyle(fontSize: 13),
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
                        label: Text(
                          widget.isSaved ? l10n.commonSaved : l10n.commonSave,
                        ),
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
